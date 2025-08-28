/// File: debate_chatgpt_service.dart
/// Purpose: 토론 주제에 대한 AI 응답(자연스러운 대화체) + 끊김 자동복구 + 입장 고정(사용자 반대편) + KPI 메타 파싱
/// Author: 박민준 (개선 반영)
/// Last Modified: 2025-08-28

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// UI에 표시할 본문 + META에서 필요한 최소 정보
class DebateTurn {
  final String displayText;       // UI에 보여줄 본문(EOM 이전)
  final String stanceReported;    // META의 stance ("pro" | "con")
  final int claims;               // 주장 개수
  final bool rebuttalIncluded;    // 반박 포함 여부
  final List<String> sources;     // 간단 출처 목록

  DebateTurn({
    required this.displayText,
    required this.stanceReported,
    required this.claims,
    required this.rebuttalIncluded,
    required this.sources,
  });
}

/// 토론 전용 KPI (프롬프트 특화 지표만)
class DebateKpi {
  final int jsonValid;               // META 파싱 성공(0/1)
  final int stanceConsistency;       // 기대 입장과 META 입장 일치(0/1)
  final int claimsCompleteness;      // claims >= 2 (0/1)
  final int followupQuestion;        // 마지막 문장이 질문으로 끝남(0/1)
  final int rebuttalIncluded;        // 반박 포함(0/1)
  final int sourcesIncluded;         // 출처 포함(0/1)

  DebateKpi({
    required this.jsonValid,
    required this.stanceConsistency,
    required this.claimsCompleteness,
    required this.followupQuestion,
    required this.rebuttalIncluded,
    required this.sourcesIncluded,
  });

  Map<String, dynamic> toJson() => {
    'json_valid': jsonValid,
    'stance_consistency': stanceConsistency,
    'claims_completeness': claimsCompleteness,
    'followup_question': followupQuestion,
    'rebuttal_included': rebuttalIncluded,
    'sources_included': sourcesIncluded,
    'ts': DateTime.now().toIso8601String(),
  };
}

class DebateGPTService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// 모델 교체를 쉽게 하도록 주입형으로 둡니다.
  /// 권장: 'gpt-4.1-mini' (비용/속도 균형) / 가능하면 'gpt-5'
  final String model;

  /// 기존 코드 호환을 위해 chat.completions 유지 (Responses 전환시 endpoint만 바꾸면 됨)
  final Uri endpoint;

  DebateGPTService({
    this.model = 'gpt-4o',
    String endpointUrl = 'https://api.openai.com/v1/chat/completions',
  }) : endpoint = Uri.parse(endpointUrl);

  /// 공개 API: DebateTurn + KPI 동시 반환
  ///
  /// [userStance]: 사용자의 입장 ("pro" | "con" | "찬성" | "반대")
  /// AI는 항상 반대편을 자동으로 담당합니다.
  Future<(DebateTurn, DebateKpi)> getDebateTurn({
    required String topic,
    required String userStance,
    required List<Map<String, String>> conversationHistory, // [{role, content}]
    required String userInput,
  }) async {
    final aiStance = _flipStance(userStance); // 🔒 AI는 항상 반대편
    final raw = await _requestOnce(
      topic: topic,
      aiStance: aiStance,
      conversationHistory: conversationHistory,
      userInput: userInput,
    );

    // 끊김/형식 확인 → 미완결이면 자동 이어쓰기
    final completed = await _ensureComplete(
      raw,
      topic: topic,
      aiStance: aiStance,
      conversationHistory: conversationHistory,
    );

    // 파싱
    var turn = _parseTurn(completed);

    // 입장 드리프트 방지: META stance 불일치 시 자동 재작성
    if (turn.stanceReported != aiStance) {
      final fixed = await _rewriteWithStance(
        original: completed,
        topic: topic,
        aiStance: aiStance,
      );
      turn = _parseTurn(fixed);
    }

    final kpi = _calcKpi(turn, expectedStance: aiStance);
    return (turn, kpi);
  }

  /// 하위 호환: 문자열만 필요할 때
  Future<String> getDebateResponse({
    required String topic,
    required List<Map<String, String>> conversationHistory,
    required String userInput,
    String userStance = 'pro',
  }) async {
    final (turn, _) = await getDebateTurn(
      topic: topic,
      userStance: userStance,
      conversationHistory: conversationHistory,
      userInput: userInput,
    );
    return turn.displayText;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 내부 구현
  // ────────────────────────────────────────────────────────────────────────────

  String _flipStance(String userStance) {
    final s = userStance.trim().toLowerCase();
    if (s.startsWith('pro') || s == '찬성') return 'con';
    return 'pro';
  }

  String _stanceKo(String stance) => (stance == 'con') ? '반대' : '찬성';

  /// 1) 1차 요청
  Future<String> _requestOnce({
    required String topic,
    required String aiStance, // "pro" | "con"
    required List<Map<String, String>> conversationHistory,
    required String userInput,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    final stanceKo = _stanceKo(aiStance);
    final userStanceEn = _flipStance(aiStance) == 'pro' ? 'pro' : 'con'; // 사용자 입장(영문)

    final systemPrompt = '''
너는 사용자와 하나의 주제에 대해 토론하는 AI다.
- Assistant stance(너): "$aiStance"  // ${_stanceKo(aiStance)}
- User stance(상대): "$userStanceEn"  // (Assistant의 반대편)
너의 입장은 반드시 유지한다(사용자가 어떤 주장을 하더라도 입장 바꾸지 않음).

[출력 형식]
1) 사람과 대화하듯 자연스러운 한국어 문장으로 2~4문단 작성
   - 첫 줄에 반드시 "[입장: $stanceKo]"를 넣어라.
   - 최소 2개의 핵심 주장과 간단 근거를 담아라.
   - 상대(User)의 주장 요지를 1줄 요약 후, 그에 대한 **반박**을 1줄 이상 제시하라.
   - 마지막 문장은 반드시 상대에게 되묻는 질문 1문장으로 끝내라.
   - 응답 맨 끝에 "【EOM】"을 붙여 완결을 표시하라.
2) 이어서 메타 블록을 출력하라:
<META>
{"stance":"$aiStance","claims":<정수>,"rebuttal":true|false,"sources":["일반지식" 또는 간단 출처]}
</META>

[금지]
- JSON이나 META 외의 기술적 주석을 본문 사이에 끼우지 마라.
- 장황한 서론, 인신공격, 주제 이탈 금지.
- 토큰이 부족할 상황이면 서술을 압축하되 형식(입장 표기, 질문, EOM, META)은 반드시 유지한다.
''';

    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': 'topic: $topic'},
      {'role': 'user', 'content': 'your_stance: $aiStance'},
      ...conversationHistory, // [{role:'user'|'assistant', content:'...'}]
      {'role': 'user', 'content': userInput},
    ];

    final response = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': 700,      // 🔧 끊김 방지: 여유치
        'temperature': 0.6,     // 논리 일관성 강화
        'n': 1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final text = (data['choices'][0]['message']['content'] as String).trim();
    return text;
  }

  /// 2) 완결성 체크 후 이어쓰기(self-heal)
  Future<String> _ensureComplete(
      String text, {
        required String topic,
        required String aiStance,
        required List<Map<String, String>> conversationHistory,
      }) async {
    final hasEom = text.contains('【EOM】');
    final hasMeta = text.contains('<META>') && text.contains('</META>');
    if (hasEom && hasMeta) return text;

    final fixPrompt = '''
이전 응답을 마무리하라. 규칙:
- 같은 형식 유지(본문은 사람 말투, 끝에 "【EOM】", 이어서 <META>...</META>).
- 중복 문장 최소화, 빠진 부분만 보완.
- META는 내 입장("$aiStance")을 일관되게 반영.
- topic: $topic

이전 응답(참고):
$text
''';

    final response = await http.post(
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
            'content': '너는 앞선 응답을 완결하는 도우미다. 형식을 지켜 마무리만 하라.'
          },
          {'role': 'user', 'content': fixPrompt},
        ],
        'max_tokens': 400,
        'temperature': 0.6,
      }),
    );

    if (response.statusCode != 200) return text; // 실패시 원문 반환
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final add = (data['choices'][0]['message']['content'] as String).trim();

    final merged = _smartMerge(text, add);
    return merged;
  }

  /// 3) 스탠스 오염 시 강제 재작성
  Future<String> _rewriteWithStance({
    required String original,
    required String topic,
    required String aiStance,
  }) async {
    final fixPrompt = '''
아래 응답은 지정된 입장("$aiStance")을 지키지 못했다.
같은 내용/논거를 보존하되, 반드시 "$aiStance" 입장으로 재작성하라.
형식은 동일하게 유지: 본문(사람 말투) → "【EOM】" → <META>...</META>
topic: $topic

원문:
$original
''';

    final response = await http.post(
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
            'content': '너는 잘못된 입장을 바로잡아 재작성하는 도우미다.'
          },
          {'role': 'user', 'content': fixPrompt},
        ],
        'max_tokens': 600,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode != 200) return original;
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return (data['choices'][0]['message']['content'] as String).trim();
  }

  /// 4) 간단 병합: 본문(EOM 전까지)만 보완 + META는 하나만 남김
  String _smartMerge(String a, String b) {
    final aHasMeta = a.contains('<META>');
    final bHasMeta = b.contains('<META>');
    final String bodyA = a;
    String bodyB = b;

    if (bHasMeta) {
      bodyB = b.split('<META>').first.trim();
    }
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
    if (meta.isNotEmpty && !out.contains('<META>')) {
      out = '$out\n$meta';
    }
    return out.trim();
  }

  /// 5) 파싱: 본문 & META
  DebateTurn _parseTurn(String full) {
    final eomIndex = full.indexOf('【EOM】');
    final display = (eomIndex >= 0 ? full.substring(0, eomIndex) : full).trim();

    Map<String, dynamic> meta = {};
    try {
      final start = full.indexOf('<META>');
      final end = full.indexOf('</META>');
      if (start >= 0 && end > start) {
        final jsonStr = full.substring(start + 6, end).trim();
        meta = jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {
      meta = {};
    }

    final stance = (meta['stance'] ?? '').toString();
    final claims = int.tryParse('${meta['claims'] ?? '0'}') ?? 0;
    final rebuttal = (meta['rebuttal'] == true);
    final sources = (meta['sources'] is List)
        ? (meta['sources'] as List).map((e) => '$e').toList()
        : <String>[];

    return DebateTurn(
      displayText: display,
      stanceReported: stance,
      claims: claims,
      rebuttalIncluded: rebuttal,
      sources: sources,
    );
  }

  /// 6) KPI 계산(토론 특화)
  DebateKpi _calcKpi(DebateTurn t, {required String expectedStance}) {
    final jsonValid = (t.stanceReported.isNotEmpty) ? 1 : 0;
    final stanceConsistency = (t.stanceReported == expectedStance) ? 1 : 0;
    final claimsCompleteness = (t.claims >= 2) ? 1 : 0;

    // 마지막 문장이 질문인지(물음표 여부) — 간단 휴리스틱
    final lastLine =
        t.displayText.split('\n').where((s) => s.trim().isNotEmpty).lastOrNull ?? '';
    final end = lastLine.trim();
    final followupQuestion =
    (end.endsWith('?') || end.endsWith('？')) ? 1 : 0;

    final rebuttalIncluded = t.rebuttalIncluded ? 1 : 0;
    final sourcesIncluded = t.sources.isNotEmpty ? 1 : 0;

    return DebateKpi(
      jsonValid: jsonValid,
      stanceConsistency: stanceConsistency,
      claimsCompleteness: claimsCompleteness,
      followupQuestion: followupQuestion,
      rebuttalIncluded: rebuttalIncluded,
      sourcesIncluded: sourcesIncluded,
    );
  }
}

/// Iterable 확장: lastOrNull
extension _LastOrNull<E> on Iterable<E> {
  E? get lastOrNull {
    final it = iterator;
    E? last;
    while (it.moveNext()) {
      last = it.current;
    }
    return last;
  }
}
