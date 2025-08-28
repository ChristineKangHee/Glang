/// File: reading_chatbot_service.dart
/// Purpose: 읽기 중 활동 - 선택 문장 기반 대화형 응답(자연스러운 말투) + 근거 세그먼트 인용 + 끊김 방지 + KPI
/// Author: 박민준 (개선 반영)
/// Last Modified: 2025-08-28

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 모델 출력에서 UI에 보여줄 본문 + META 파싱 결과
class ReadingTurn {
  final String displayText;          // UI에 표시할 본문 (【EOM】 이전)
  final List<int> citations;         // 참조한 textSegments 인덱스 목록
  final bool grounded;               // 근거 기반 여부 (META 판단/보정)
  final int sentenceCount;           // 본문 문장 수(간이 추정)

  ReadingTurn({
    required this.displayText,
    required this.citations,
    required this.grounded,
    required this.sentenceCount,
  });
}

/// 읽기-중 프롬프트 전용 KPI
class ReadingKpi {
  final int jsonValid;               // META 파싱 성공 0/1
  final int citationsIncluded;       // citations 비어있지 않음 0/1
  final int lengthCompliance;        // 문장수 <= 4 0/1
  final int followupQuestion;        // 마지막 문장이 질문으로 끝남 0/1
  final double relevanceJaccard;     // 선택문장과 응답의 토큰 Jaccard (0~1)
  final int groundedFlag;            // grounded == true 0/1

  ReadingKpi({
    required this.jsonValid,
    required this.citationsIncluded,
    required this.lengthCompliance,
    required this.followupQuestion,
    required this.relevanceJaccard,
    required this.groundedFlag,
  });

  Map<String, dynamic> toJson() => {
    'json_valid': jsonValid,
    'citations_included': citationsIncluded,
    'length_compliance': lengthCompliance,
    'followup_question': followupQuestion,
    'relevance_jaccard': relevanceJaccard,
    'grounded': groundedFlag,
    'ts': DateTime.now().toIso8601String(),
  };
}

class ChatBotService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// 교체 쉬움: 'gpt-4o' 기본. 필요 시 'gpt-5' 등으로 바꾸면 됨.
  final String model;
  final Uri endpoint;

  ChatBotService({
    this.model = 'gpt-4o', // 추후 테스트 후 4.1 mini로 바꿔도 좋을 듯 함
     String endpointUrl = 'https://api.openai.com/v1/chat/completions',
  }) : endpoint = Uri.parse(endpointUrl);

  /// 공개 API: 본문 + KPI 동시 반환
  ///
  /// [selectedText] : 사용자가 드래그/선택한 문장
  /// [textSegments] : 지문을 문단/문장 단위로 나눈 배열(인덱스가 근거 인용에 쓰임)
  /// [messages]     : 기존 대화 히스토리 [{role, content}]
  Future<(ReadingTurn, ReadingKpi)> getChatTurn(
      String selectedText,
      List<String> textSegments,
      List<Map<String, String>> messages,
      ) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    // 1) 컨텍스트 윈도우 구성: selectedText가 포함된 세그먼트와 인접부만 전달(토큰 절약)
    final ctx = _buildContextWindow(selectedText, textSegments, window: 1);

    // 2) 1차 요청
    final raw = await _requestOnce(
      selectedText: selectedText,
      contextSegments: ctx.windowSegments,
      contextIndices: ctx.windowIndices,
      messages: messages,
    );

    // 3) 끊김/형식 검사 후 Self-heal
    final completed = await _ensureComplete(
      raw,
      selectedText: selectedText,
      contextSegments: ctx.windowSegments,
      contextIndices: ctx.windowIndices,
    );

    // 4) 파싱
    final turn = _parseTurn(completed);

    // 5) KPI 계산
    final kpi = _calcKpi(
      turn: turn,
      selectedText: selectedText,
    );

    return (turn, kpi);
  }

  /// 하위 호환: 문자열만 필요할 때
  Future<String> getChatResponse(
      String selectedText,
      List<String> textSegments,
      List<Map<String, String>> messages,
      ) async {
    final (turn, _) = await getChatTurn(selectedText, textSegments, messages);
    return turn.displayText;
  }

  // ───────────────────────── 내부 구현 ─────────────────────────

  /// 컨텍스트 윈도우(선택세그먼트 ±N)
  _Ctx _buildContextWindow(String selectedText, List<String> segs, {int window = 1}) {
    int hit = -1;
    for (int i = 0; i < segs.length; i++) {
      if (segs[i].contains(selectedText)) {
        hit = i;
        break;
      }
    }
    // 못 찾으면 가장 유사(간단히 길이/공유토큰 최대) 세그먼트 선택
    if (hit == -1) {
      int best = 0; double bestScore = -1;
      for (int i = 0; i < segs.length; i++) {
        final s = _jaccard(_tokenize(selectedText), _tokenize(segs[i]));
        if (s > bestScore) { best = i; bestScore = s; }
      }
      hit = best;
    }

    final start = (hit - window).clamp(0, segs.length - 1);
    final end = (hit + window).clamp(0, segs.length - 1);
    final indices = <int>[];
    final windowSegs = <String>[];
    for (int i = start; i <= end; i++) {
      indices.add(i);
      windowSegs.add(segs[i]);
    }
    return _Ctx(windowSegs, indices);
  }

  /// 1차 요청
  Future<String> _requestOnce({
    required String selectedText,
    required List<String> contextSegments,
    required List<int> contextIndices,
    required List<Map<String, String>> messages,
  }) async {
    final systemPrompt = '''
너는 학생의 "읽기 중" 활동을 돕는 대화형 튜터다.
- 학생이 선택한 문장을 바탕으로 **본문에 근거하여** 간결하게 설명하고, 마지막에 학생이 생각을 확장할 수 있도록 질문 1개로 끝내라.
- 말투는 자연스러운 한국어, 불릿 목록 금지, 2~4문장 이내.
- 응답은 아래 형식을 따를 것:
(1) 본문: 자연스러운 문장 → 끝에 "【EOM】"
(2) 이어서 META JSON을 <META>...</META> 사이에 출력:
<META>
{"citations":[세그먼트_인덱스_정수_배열],"grounded":true|false}
</META>
주의: META 외 임의의 기호나 주석, 코드블록 금지. 본문에는 인덱스 표시하지 말 것.
''';

    final userContext =
        'Selected: "$selectedText"\nContextSegments:\n' +
            List.generate(contextSegments.length,
                    (i) => '- [${contextIndices[i]}] ${contextSegments[i]}')
                .join('\n');

    final payload = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userContext},
        ...messages, // [{role:'user'|'assistant', content:'...'}]
        {
          'role': 'user',
          'content':
          '위 컨텍스트를 바탕으로 2~4문장으로 답하고, 마지막 문장은 질문으로 마무리해. 끝에 "【EOM】". 그리고 <META>{"citations":[...],"grounded":...}</META>를 붙여.'
        },
      ],
      'max_tokens': 420,     // 끊김 방지 여유
      'temperature': 0.5,    // 일관성/근거 중심
      'n': 1,
    };

    final resp = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception('OpenAI error ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final text = (data['choices'][0]['message']['content'] as String).trim();
    return text;
  }

  /// Self-heal: EOM/META 누락 시 보완
  Future<String> _ensureComplete(
      String text, {
        required String selectedText,
        required List<String> contextSegments,
        required List<int> contextIndices,
      }) async {
    final hasEom = text.contains('【EOM】');
    final hasMeta = text.contains('<META>') && text.contains('</META>');
    if (hasEom && hasMeta) return text;

    final fixPrompt = '''
아래 응답을 형식에 맞게 마무리하라. 규칙:
- 본문은 2~4문장, 마지막은 질문으로 끝나고 "【EOM】" 포함.
- 이어서 <META>{"citations":[...],"grounded":true|false}</META> 출력.
- citations에는 실제 참조한 세그먼트 인덱스를 넣어라. 가능한 한 위 컨텍스트에서 선택하라.

선택 문장: "$selectedText"
컨텍스트(인덱스 포함):
${List.generate(contextSegments.length, (i) => '[${contextIndices[i]}] ${contextSegments[i]}').join('\n')}

이전 응답:
$text
''';

    final resp = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': '너는 응답을 완결/정형화하는 도우미다. 형식을 철저히 지켜 보완하라.'
          },
          {'role': 'user', 'content': fixPrompt},
        ],
        'max_tokens': 320,
        'temperature': 0.4,
      }),
    );

    if (resp.statusCode != 200) return text;
    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final add = (data['choices'][0]['message']['content'] as String).trim();
    return _smartMerge(text, add);
  }

  /// 간단 병합: 본문(EOM 전까지) 보완 + META는 하나만 유지
  String _smartMerge(String a, String b) {
    final aHasMeta = a.contains('<META>');
    final bHasMeta = b.contains('<META>');
    String bodyA = a;
    String bodyB = b;

    if (bHasMeta) bodyB = b.split('<META>').first.trim();

    String out = bodyA.trim();
    if (!out.contains('【EOM】')) {
      out = (out + '\n' + bodyB).trim();
    }

    String meta = '';
    if (bHasMeta) {
      meta = '<META>' +
          b.split('<META>').last.split('</META>').first +
          '</META>';
    } else if (aHasMeta) {
      meta = '<META>' +
          a.split('<META>').last.split('</META>').first +
          '</META>';
    }

    if (!out.contains('【EOM】')) out = '$out【EOM】';
    if (meta.isNotEmpty && !out.contains('<META>')) out = '$out\n$meta';
    return out.trim();
  }

  /// 파싱: 본문 & META
  ReadingTurn _parseTurn(String full) {
    final eomIdx = full.indexOf('【EOM】');
    final display = (eomIdx >= 0 ? full.substring(0, eomIdx) : full).trim();

    Map<String, dynamic> meta = {};
    try {
      final s = full.indexOf('<META>');
      final e = full.indexOf('</META>');
      if (s >= 0 && e > s) {
        final jsonStr = full.substring(s + 6, e).trim();
        meta = jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {
      meta = {};
    }

    final citations = <int>[];
    if (meta['citations'] is List) {
      for (final v in (meta['citations'] as List)) {
        final n = int.tryParse('$v');
        if (n != null) citations.add(n);
      }
    }
    final grounded = meta['grounded'] == true;

    final sentenceCount = _countSentences(display);

    return ReadingTurn(
      displayText: display,
      citations: citations,
      grounded: grounded,
      sentenceCount: sentenceCount,
    );
  }

  /// KPI 계산
  ReadingKpi _calcKpi({
    required ReadingTurn turn,
    required String selectedText,
  }) {
    final jsonValid = (turn.citations.isNotEmpty || turn.grounded != false) ? 1 : 0;
    final citationsIncluded = turn.citations.isNotEmpty ? 1 : 0;
    final lengthCompliance = (turn.sentenceCount <= 4 && turn.sentenceCount > 0) ? 1 : 0;

    final lastLine =
        turn.displayText.split('\n').where((s) => s.trim().isNotEmpty).lastOrNull ?? '';
    final end = lastLine.trim();
    final followupQuestion = (end.endsWith('?') || end.endsWith('？')) ? 1 : 0;

    final j = _jaccard(_tokenize(selectedText), _tokenize(turn.displayText));

    final groundedFlag = turn.grounded ? 1 : 0;

    return ReadingKpi(
      jsonValid: jsonValid,
      citationsIncluded: citationsIncluded,
      lengthCompliance: lengthCompliance,
      followupQuestion: followupQuestion,
      relevanceJaccard: j,
      groundedFlag: groundedFlag,
    );
  }

  // ───────────────────────── 유틸 ─────────────────────────

  int _countSentences(String s) {
    // 매우 단순한 분리(., !, ?, …, 。, ！, ？)
    final reg = RegExp(r'[\.!\?…。！？]+');
    final parts = s.split(reg).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.length;
  }

  Set<String> _tokenize(String s) {
    final cleaned = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9가-힣\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final tokens = cleaned.split(' ').where((t) => t.length >= 2).toSet();
    return tokens;
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final inter = a.intersection(b).length.toDouble();
    final uni = a.union(b).length.toDouble();
    return inter / uni;
  }
}

class _Ctx {
  final List<String> windowSegments;
  final List<int> windowIndices;
  _Ctx(this.windowSegments, this.windowIndices);
}

/// Iterable 확장: lastOrNull
extension _LastOrNull<E> on Iterable<E> {
  E? get lastOrNull {
    final it = iterator;
    E? last;
    while (it.moveNext()) { last = it.current; }
    return last;
  }
}
