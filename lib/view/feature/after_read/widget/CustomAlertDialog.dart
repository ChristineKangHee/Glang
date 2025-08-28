/// File: CustomAlertDialog.dart
/// Purpose: 읽기 후 활동 평가 — 진단 기반 재채점(만점 편향 억제)
///   - Responses API 우선 + Chat Completions 폴백
///   - JSON 스키마 강제(진단 체크리스트 포함)
///   - 최소 글자수, Self-heal, 로깅
///   - 모델 원시 점수 무시 → 클라이언트가 진단 + 휴리스틱으로 점수 재계산
/// Last Modified: 2025-08-29

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:shimmer/shimmer.dart';
import 'alert_section_button.dart';

class CustomAlertDialog extends StatelessWidget {
  final String answerText;
  final String readingText;
  final String activityType; // "요약하기" | "결말 바꾸기" | "에세이 작성" | "형식 변환 연습" | "표지 보고 유추하기"

  const CustomAlertDialog({
    Key? key,
    required this.answerText,
    required this.readingText,
    required this.activityType,
  }) : super(key: key);

  // 채점 강도(1=온건, 2=보통, 3=엄격)
  static const int strictness = 2;

  // 실패 시 기본값(파싱/네트워크 오류 대비)
  static const Map<String, dynamic> defaultAnalysisResponse = {
    "expression": 3,
    "logic": 3,
    "composition": 3,
    "feedback": "정보 없음",
    "modelAnswer": "정보 없음",
  };

  // ───────────────────────── 내부 로깅 ─────────────────────────
  void _log(String tag, Object msg) {
    final s = msg.toString();
    final cut = s.length > 2000 ? (s.substring(0, 2000) + '…(truncated)') : s;
    // ignore: avoid_print
    print('[AfterReading][$tag] $cut');
  }

  // ── 길이 정책(최소 글자 수) ─────────────────────────────────────────────
  Map<String, int> _minChars(String activityType) {
    // 활동별로 모범답안은 조금 더 길게 요구
    switch (activityType) {
      case '결말 바꾸기':
        return {"feedback": 100, "modelAnswer": 160};
      case '에세이 작성':
        return {"feedback": 100, "modelAnswer": 140};
      default: // 요약/형식변환/표지유추 등
        return {"feedback": 80, "modelAnswer": 100};
    }
  }

  // ── Responses API용 JSON 스키마(키 강제 + 진단 체크리스트) ─────────────
  Map<String, dynamic> _jsonSchemaWithMin(int minFb, int minMa) => {
    "name": "AfterReadingEvaluation",
    "schema": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "expression": {"type": "integer", "minimum": 1, "maximum": 5},
        "logic": {"type": "integer", "minimum": 1, "maximum": 5},
        "composition": {"type": "integer", "minimum": 1, "maximum": 5},
        "feedback": {"type": "string", "minLength": minFb, "maxLength": 1200},
        "modelAnswer": {"type": "string", "minLength": minMa, "maxLength": 1600},
        "diagnostics": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "evidenceQuotes": {
              "type": "array",
              "items": {"type": "string"},
              "minItems": 0,
              "maxItems": 3
            },
            "expressionChecks": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "clarityGood": {"type": "boolean"},
                "variedVocab": {"type": "boolean"},
                "sentenceVariety": {"type": "boolean"},
                "toneAppropriate": {"type": "boolean"},
                "grammarIssues": {"type": "integer", "minimum": 0}
              },
              "required": [
                "clarityGood",
                "variedVocab",
                "sentenceVariety",
                "toneAppropriate",
                "grammarIssues"
              ]
            },
            "logicChecks": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "keyPointsCovered": {"type": "integer", "minimum": 0},
                "reasoningFlaws": {"type": "integer", "minimum": 0},
                "contradictions": {"type": "integer", "minimum": 0},
                "fabrication": {"type": "integer", "minimum": 0},
                "usesEvidence": {"type": "boolean"}
              },
              "required": [
                "keyPointsCovered",
                "reasoningFlaws",
                "contradictions",
                "fabrication",
                "usesEvidence"
              ]
            },
            "compositionChecks": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "hasStructure": {"type": "boolean"},
                "transitionIssues": {"type": "integer", "minimum": 0},
                "redundancyIssues": {"type": "integer", "minimum": 0},
                "coherenceIssues": {"type": "integer", "minimum": 0}
              },
              "required": [
                "hasStructure",
                "transitionIssues",
                "redundancyIssues",
                "coherenceIssues"
              ]
            }
          },
          "required": [
            "evidenceQuotes",
            "expressionChecks",
            "logicChecks",
            "compositionChecks"
          ]
        }
      },
      "required": [
        "expression",
        "logic",
        "composition",
        "feedback",
        "modelAnswer",
        "diagnostics"
      ]
    },
    "strict": true
  };

  // 2차 보정용(텍스트만) 스키마
  Map<String, dynamic> _jsonSchemaTextOnly(int minFb, int minMa) => {
    "name": "AfterReadingTextFill",
    "schema": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "feedback": {"type": "string", "minLength": minFb, "maxLength": 1200},
        "modelAnswer": {"type": "string", "minLength": minMa, "maxLength": 1600}
      },
      "required": ["feedback", "modelAnswer"]
    },
    "strict": true
  };

  // 활동별 루브릭
  String _buildRubric(String activityType) {
    switch (activityType) {
      case '요약하기':
        return '''
- 채점 기준: (핵심 포착/불필요 정보 배제/일관된 흐름)
- 피드백: 누락·과잉·왜곡 지점과 개선 팁 2~3가지.
- 모범답안: 2~4문장 한국어 요약, 새로운 사실 추가 금지.''';
      case '결말 바꾸기':
        return '''
- 채점 기준: (설정·인물 성격 정합/개연성/창의성/완결성)
- 피드백: 개연성 보완 포인트 2가지 이상.
- 모범답안: 5~7문장 대안 결말, 세계관 위배 금지.''';
      case '에세이 작성':
        return '''
- 채점 기준: (주장 명료성/근거 관련성/구성 논리성/문체 일관성)
        - 피드백: 주제문 개선, 근거 보강 제안 각각 1개 이상.
- 모범답안: 120~180자 단락(서론-근거-정리).''';
      case '형식 변환 연습':
        return '''
- 채점 기준: (의미 보존/목표 형식 준수/문체 일관성)
- 피드백: 형식 규칙 위반 지점과 수정 예시.
- 모범답안: 목표 형식에 맞춘 변환본(3~6문장).''';
      case '표지 보고 유추하기':
        return '''
- 채점 기준: (표지 단서 활용/합리적 추론/과도한 단정 회피/명료성)
- 피드백: 단서→추론 연결을 2가지 이상 지적.
- 모범답안: 3~5문장 추론, 불확실성 수식 포함.''';
      default:
        return '''
- 채점 기준: (표현력/논리력/구성력 전반)
- 피드백: 구체적 개선 팁 2~3가지.
- 모범답안: 활동에 맞는 간결 예시.''';
    }
  }

  // 긴 원문은 토큰 보호를 위해 자르기
  String _truncate(String s, int max) => (s.length <= max) ? s : (s.substring(0, max) + '…');

  // ── 메인 호출: Responses 우선 → 실패 시 Chat Completions 폴백 ───────────
  Future<Map<String, dynamic>> fetchAnswerAnalysis(
      String answerText, String readingText, String activityType) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return defaultAnalysisResponse;

    final limits = _minChars(activityType);
    final minFb = limits['feedback']!;
    final minMa = limits['modelAnswer']!;
    final rubric = _buildRubric(activityType);

    final String sys = '''
너는 초중등 학생의 '읽기 후 활동' 채점자이자 피드백 코치다.
반드시 한국어로 답하라.
점수는 1~5의 정수이며, "feedback"은 최소 ${minFb}자, "modelAnswer"는 최소 ${minMa}자로 작성하라.
활동에 맞는 루브릭을 적용하고, 아래 지침을 준수하라.
[채점 지침]
- 기본 점수는 3점에서 시작해 증거와 오류에 따라 가감한다.
- 5점 부여 금지(아래 조건 모두 충족 시에만 5점 허용):
  (i) 핵심 요지 오해 없음, (ii) 원문 근거 인용 1개 이상,
  (iii) 구조적 결함 없음, (iv) 추론 오류/날조/장황함 없음, (v) 문법 오류 2건 이내.
- 먼저 diagnostics를 산출하고, 그 결과를 반영하여 expression/logic/composition을 산출한다.
- 출력은 지정된 JSON 스키마와 완전히 일치해야 한다.

$rubric
출력 키: expression, logic, composition, feedback, modelAnswer, diagnostics
''';

    // ── (A) Responses API 시도 ────────────────────────────────────────────
    try {
      final Uri url = Uri.parse('https://api.openai.com/v1/responses');
      const String model = 'gpt-4o'; // 필요 시 'gpt-5'

      Map<String, dynamic> payload({bool strictRemind = false}) => {
        "model": model,
        "input": [
          {
            "role": "system",
            "content": strictRemind
                ? "이전 응답이 스키마/길이/채점 지침을 지키지 않았다. diagnostics를 먼저 산출하고, 지침에 맞게 점수를 주어라. 정확한 JSON만 출력."
                : sys
          },
          {"role": "user", "content": "활동 유형: $activityType"},
          {"role": "user", "content": "학생 답변:\n${_truncate(answerText, 4000)}"},
          {"role": "user", "content": "원문(참조):\n${_truncate(readingText, 6000)}"}
        ],
        "temperature": 0.2,
        "max_output_tokens": 1200,
        "response_format": {
          "type": "json_schema",
          "json_schema": _jsonSchemaWithMin(minFb, minMa)
        }
      };

      final resp1 = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload()),
      );
      _log('responses.status', resp1.statusCode);
      if (resp1.statusCode == 200) {
        final data1 = jsonDecode(utf8.decode(resp1.bodyBytes));
        final text1 = _extractText(data1);
        var parsed1 = _safeJsonDecode(text1);
        parsed1 = _postValidate(parsed1);
        var final1 = _calibrateScores(
          parsed1, activityType,
          strictness: strictness,
          answerText: answerText,
          readingText: readingText,
        );

        // 길이/키 확인
        final fbOk = _lenOk(final1['feedback'], minFb);
        final maOk = _lenOk(final1['modelAnswer'], minMa);
        if (fbOk && maOk && _hasAllKeys(final1)) {
          return final1;
        }

        // Self-heal(Responses 재요청)
        final resp2 = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(payload(strictRemind: true)),
        );
        _log('responses.retry.status', resp2.statusCode);
        if (resp2.statusCode == 200) {
          final data2 = jsonDecode(utf8.decode(resp2.bodyBytes));
          final text2 = _extractText(data2);
          var parsed2 = _safeJsonDecode(text2);
          parsed2 = _postValidate(parsed2);
          var final2 = _calibrateScores(
            parsed2, activityType,
            strictness: strictness,
            answerText: answerText,
            readingText: readingText,
          );
          if (_lenOk(final2['feedback'], minFb) &&
              _lenOk(final2['modelAnswer'], minMa) &&
              _hasAllKeys(final2)) {
            return final2;
          }
        }
      } else {
        _log('responses.error', resp1.body);
      }
    } catch (e) {
      _log('responses.exception', e);
    }

    // ── (B) 폴백: Chat Completions(JSON 모드) ─────────────────────────────
    try {
      final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
      const String model = 'gpt-4o'; // 필요 시 'gpt-5'

      final sys2 = '''
너는 초중등 학생의 '읽기 후 활동' 채점 및 피드백 전문가다.
반드시 한국어. 기본 3점에서 시작해 증거/오류로 가감.
5점 금지 조건을 적용하고, 먼저 diagnostics를 산출한 다음 점수를 내라.
필수 키: expression, logic, composition, feedback, modelAnswer, diagnostics
예시(형식만 참고):
{"expression":3,"logic":3,"composition":3,"feedback":"...","modelAnswer":"...","diagnostics":{"evidenceQuotes":["원문 인용1"],"expressionChecks":{"clarityGood":true,"variedVocab":true,"sentenceVariety":true,"toneAppropriate":true,"grammarIssues":0},"logicChecks":{"keyPointsCovered":2,"reasoningFlaws":0,"contradictions":0,"fabrication":0,"usesEvidence":true},"compositionChecks":{"hasStructure":true,"transitionIssues":0,"redundancyIssues":0,"coherenceIssues":0}}}
''';

      Map<String, dynamic> payload() => {
        'model': model,
        'messages': [
          {'role': 'system', 'content': sys2},
          {'role': 'user', 'content': '활동 유형: $activityType'},
          {'role': 'user', 'content': '학생 답변:\n${_truncate(answerText, 4000)}'},
          {'role': 'user', 'content': '원문(참조):\n${_truncate(readingText, 6000)}'},
          {'role': 'user', 'content': '오직 위 JSON 객체 **그 자체만** 출력해.'},
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.2,
        'max_tokens': 1300,
      };

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload()),
      );
      _log('chat.status', resp.statusCode);
      if (resp.statusCode != 200) {
        _log('chat.error', resp.body);
        return defaultAnalysisResponse;
      }

      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      final raw = (data['choices'][0]['message']['content'] ?? '').toString();
      var parsed = _safeJsonDecode(raw);
      parsed = _postValidate(parsed);
      var adjusted = _calibrateScores(
        parsed, activityType,
        strictness: strictness,
        answerText: answerText,
        readingText: readingText,
      );

      // 길이 보정 필요 시, 텍스트 필드만 보강
      if (!_lenOk(adjusted['feedback'], minFb) || !_lenOk(adjusted['modelAnswer'], minMa)) {
        final fill = await _fallbackRefillViaChat(
          apiKey: apiKey,
          model: model,
          activityType: activityType,
          answerText: answerText,
          readingText: readingText,
          minFb: minFb,
          minMa: minMa,
        );
        adjusted['feedback'] = fill['feedback'] ?? adjusted['feedback'];
        adjusted['modelAnswer'] = fill['modelAnswer'] ?? adjusted['modelAnswer'];
      }

      return adjusted;
    } catch (e) {
      _log('chat.exception', e);
      return defaultAnalysisResponse;
    }
  }

  // ── 폴백 보강 호출(Chat): 텍스트만 강제 채우기 ─────────────────────────
  Future<Map<String, String>> _fallbackRefillViaChat({
    required String apiKey,
    required String model,
    required String activityType,
    required String answerText,
    required String readingText,
    required int minFb,
    required int minMa,
  }) async {
    final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final sys = '''
이전 응답의 "feedback" 또는 "modelAnswer"가 비었거나 너무 짧다.
반드시 한국어로, feedback 최소 ${minFb}자, modelAnswer 최소 ${minMa}자로 작성.
오직 아래 JSON 객체만 출력:
{"feedback":"...","modelAnswer":"..."}
''';

    final payload = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': sys},
        {'role': 'user', 'content': '활동 유형: $activityType'},
        {'role': 'user', 'content': '학생 답변:\n${_truncate(answerText, 4000)}'},
        {'role': 'user', 'content': '원문(참조):\n${_truncate(readingText, 6000)}'},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.2,
      'max_tokens': 900,
    };

    try {
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      );
      if (resp.statusCode != 200) {
        _log('chat.refill.error', resp.body);
        return {};
      }
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      final raw = (data['choices'][0]['message']['content'] ?? '').toString();
      final parsed = _safeJsonDecode(raw);
      return {
        "feedback": (parsed["feedback"] ?? "").toString(),
        "modelAnswer": (parsed["modelAnswer"] ?? "").toString(),
      };
    } catch (e) {
      _log('chat.refill.exception', e);
      return {};
    }
  }

  // ── 파싱/검증 유틸 ────────────────────────────────────────────────────
  String _extractText(dynamic data) {
    try {
      final outputs = data['output'] as List?;
      if (outputs != null && outputs.isNotEmpty) {
        final content = outputs.first['content'] as List?;
        if (content != null && content.isNotEmpty) {
          final first = content.first;
          if (first is Map && first['text'] is String) return first['text'];
          if (first is Map && first['type'] == 'output_text' && first['text'] is String) {
            return first['text'];
          }
        }
      }
      final choices = data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final mc = choices.first['message']?['content'];
        if (mc is String) return mc;
      }
    } catch (_) {}
    throw Exception('응답 파싱 실패');
  }

  Map<String, dynamic> _safeJsonDecode(String s) {
    try {
      final v = jsonDecode(s);
      return (v is Map<String, dynamic>) ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  bool _lenOk(dynamic v, int minChars) {
    final s = (v ?? '').toString().trim();
    return s.length >= minChars;
  }

  bool _hasAllKeys(Map<String, dynamic> m) {
    const need = {'expression', 'logic', 'composition', 'feedback', 'modelAnswer'};
    return need.every(m.containsKey);
  }

  // 파싱 보정 + 진단 필드 정규화
  Map<String, dynamic> _postValidate(Map<String, dynamic> m) {
    int clamp(num v) => v < 1 ? 1 : (v > 5 ? 5 : v.round());

    final diag = (m["diagnostics"] is Map<String, dynamic>)
        ? (m["diagnostics"] as Map<String, dynamic>)
        : <String, dynamic>{};

    Map<String, dynamic> obj(String k) =>
        (diag[k] is Map<String, dynamic>) ? (diag[k] as Map<String, dynamic>) : <String, dynamic>{};
    int asInt(dynamic v) => (v is num) ? v.round() : 0;
    bool asBool(dynamic v) => v == true;

    final expressionChecks = obj("expressionChecks");
    final logicChecks = obj("logicChecks");
    final compositionChecks = obj("compositionChecks");

    return {
      "expression": clamp(m["expression"] ?? 3),
      "logic": clamp(m["logic"] ?? 3),
      "composition": clamp(m["composition"] ?? 3),
      "feedback": (m["feedback"] ?? "").toString(),
      "modelAnswer": (m["modelAnswer"] ?? "").toString(),
      "diagnostics": {
        "evidenceQuotes": (diag["evidenceQuotes"] is List)
            ? (diag["evidenceQuotes"] as List).map((e) => '$e').toList()
            : <String>[],
        "expressionChecks": {
          "clarityGood": asBool(expressionChecks["clarityGood"]),
          "variedVocab": asBool(expressionChecks["variedVocab"]),
          "sentenceVariety": asBool(expressionChecks["sentenceVariety"]),
          "toneAppropriate": asBool(expressionChecks["toneAppropriate"]),
          "grammarIssues": asInt(expressionChecks["grammarIssues"]),
        },
        "logicChecks": {
          "keyPointsCovered": asInt(logicChecks["keyPointsCovered"]),
          "reasoningFlaws": asInt(logicChecks["reasoningFlaws"]),
          "contradictions": asInt(logicChecks["contradictions"]),
          "fabrication": asInt(logicChecks["fabrication"]),
          "usesEvidence": asBool(logicChecks["usesEvidence"]),
        },
        "compositionChecks": {
          "hasStructure": asBool(compositionChecks["hasStructure"]),
          "transitionIssues": asInt(compositionChecks["transitionIssues"]),
          "redundancyIssues": asInt(compositionChecks["redundancyIssues"]),
          "coherenceIssues": asInt(compositionChecks["coherenceIssues"]),
        }
      }
    };
  }

  // ── 텍스트 휴리스틱 ───────────────────────────────────────────────────
  Set<String> _tokenize(String s) {
    final cleaned = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9가-힣\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return <String>{};
    return cleaned.split(' ').where((t) => t.length >= 2).toSet();
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final inter = a.intersection(b).length.toDouble();
    final uni = a.union(b).length.toDouble();
    return inter / uni;
  }

  int _countSentences(String s) {
    final reg = RegExp(r'[\.!\?…。！？]+');
    final parts = s.split(reg).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.length;
  }

  // ── 🔥 점수 재계산(모델 점수 무시, 진단+휴리스틱으로 산출) ────────────────
  Map<String, dynamic> _calibrateScores(
      Map<String, dynamic> m,
      String activityType, {
        required int strictness,
        required String answerText,
        required String readingText,
      }) {
    int clamp(int v) => v < 1 ? 1 : (v > 5 ? 5 : v);

    // 휴리스틱
    final j = _jaccard(_tokenize(answerText), _tokenize(readingText)); // 0~1
    final len = answerText.trim().length;
    final sents = _countSentences(answerText);

    // 진단 추출
    final d = (m["diagnostics"] as Map<String, dynamic>? ?? {});
    final quotes = (d["evidenceQuotes"] as List<dynamic>? ?? []).cast<String>();

    Map<String, dynamic> obj(String k) =>
        (d[k] is Map<String, dynamic>) ? (d[k] as Map<String, dynamic>) : <String, dynamic>{};
    final expC = obj("expressionChecks");
    final logC = obj("logicChecks");
    final comC = obj("compositionChecks");

    bool b(dynamic v) => v == true;
    int n(dynamic v) => (v is num) ? v.round() : 0;

    // 가점/감점 기반 산출(기본 3점에서 시작)
    int exp = 3, logi = 3, comp = 3;

    // 표현력
    if (b(expC["clarityGood"])) exp++;
    if (b(expC["variedVocab"])) exp++;
    if (b(expC["sentenceVariety"])) exp++;
    if (b(expC["toneAppropriate"])) exp++;
    final gi = n(expC["grammarIssues"]);
    if (gi >= 1) exp--;
    if (gi >= 3) exp--;
    if (gi >= 6) exp--;
    if (j > 0.60) exp--;                 // 원문과 과도한 중복(표현력 감점)
    if (len < 60) exp--;                 // 지나치게 짧음
    exp = clamp(exp);

    // 논리력
    if (b(logC["usesEvidence"])) logi++;
    if (n(logC["keyPointsCovered"]) >= 2) logi++;
    if (n(logC["fabrication"]) > 0) logi -= 2;
    if (n(logC["reasoningFlaws"]) > 0) logi--;
    if (n(logC["contradictions"]) > 0) logi--;
    if (quotes.isEmpty) logi--;         // 실제 인용 없으면 감점
    if (j < 0.08) logi--;               // 거의 무관(오프토픽 가능)
    logi = clamp(logi);

    // 구성력
    if (b(comC["hasStructure"])) comp++;
    if (n(comC["transitionIssues"]) > 0) comp--;
    if (n(comC["redundancyIssues"]) > 0) comp--;
    if (n(comC["coherenceIssues"]) > 0) comp--;
    if (sents < 2 || sents > 12) comp--; // 지나치게 짧거나 장황
    comp = clamp(comp);

    // 활동별 가중
    if (activityType == '요약하기') {
      if (n(logC["keyPointsCovered"]) < 2) { logi = clamp(logi - 1); comp = clamp(comp - 1); }
      if (j > 0.70) exp = clamp(exp - 1); // 요약인데 베껴쓰기 성향
    } else if (activityType == '결말 바꾸기') {
      if (n(comC["coherenceIssues"]) > 0 || n(comC["transitionIssues"]) > 0) comp = clamp(comp - 1);
    } else if (activityType == '에세이 작성') {
      if (!b(logC["usesEvidence"])) logi = clamp(logi - 1);
      if (n(logC["reasoningFlaws"]) > 0) logi = clamp(logi - 1);
    }

    // 엄격도(Strictness)
    if (strictness == 3) {
      if (gi > 0) exp = clamp(exp - 1);
      if (n(logC["reasoningFlaws"]) > 0 || n(logC["contradictions"]) > 0 || n(logC["fabrication"]) > 0) {
        logi = clamp(logi - 1);
      }
      if (n(comC["coherenceIssues"]) > 0 || n(comC["transitionIssues"]) > 0) {
        comp = clamp(comp - 1);
      }
    } else if (strictness == 1) {
      // 너무 낮게 떨어지는 것 방지(초등 저학년 등)
      if (exp < 2) exp = 2;
      if (logi < 2) logi = 2;
      if (comp < 2) comp = 2;
    }

    // 5점 상한 조건(완벽할 때만 5 허용)
    bool perfect = quotes.isNotEmpty &&
        gi <= 1 &&
        n(logC["fabrication"]) == 0 &&
        n(logC["reasoningFlaws"]) == 0 &&
        n(logC["contradictions"]) == 0 &&
        b(comC["hasStructure"]) &&
        n(comC["transitionIssues"]) == 0 &&
        n(comC["coherenceIssues"]) == 0 &&
        j >= 0.15 && j <= 0.65 &&
        len >= 120;
    if (!perfect) {
      if (exp == 5) exp = 4;
      if (logi == 5) logi = 4;
      if (comp == 5) comp = 4;
    }

    return {
      "expression": exp,
      "logic": logi,
      "composition": comp,
      "feedback": m["feedback"],
      "modelAnswer": m["modelAnswer"],
    };
  }

  // ───────────────────────── UI ─────────────────────────────────────────

  // 레이더 차트(값 순서와 타이틀 순서 일치: 표현력 → 논리력 → 구성력)
  Widget radarchart(
      CustomColors customColors, int tickCount, BuildContext context, Map<String, dynamic> analysis) {
    return SizedBox(
      width: 250,
      height: 170,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          titlePositionPercentageOffset: 0.2,
          dataSets: [
            RadarDataSet(
              dataEntries: [
                RadarEntry(value: (analysis["expression"] as num).toDouble()),
                RadarEntry(value: (analysis["logic"] as num).toDouble()),
                RadarEntry(value: (analysis["composition"] as num).toDouble()),
              ],
              fillColor: customColors.primary40?.withOpacity(0.3),
              borderColor: customColors.primary,
              entryRadius: 4,
              borderWidth: 3,
            ),
          ],
          tickBorderData: BorderSide(color: customColors.neutral80!),
          radarBorderData: BorderSide(color: customColors.neutral80!),
          gridBorderData: BorderSide(color: customColors.neutral80!),
          borderData: FlBorderData(show: false),
          tickCount: tickCount,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          titleTextStyle:
          body_xsmall_semi(context).copyWith(color: customColors.neutral30),
          getTitle: (index, _) {
            const titles = ['표현력', '논리력', '구성력'];
            return RadarChartTitle(text: titles[index]);
          },
        ),
      ),
    );
  }

  Widget _buildInfoBox(
      BuildContext context, String title, String content, CustomColors customColors) {
    final safe = (content.trim().isEmpty) ? '정보 없음' : content;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: customColors.neutral90,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_small_semi(context)),
          const SizedBox(height: 8),
          Text(safe, style: body_small(context)),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context, CustomColors customColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("결과",
            style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              width: 130,
              height: 100,
              color: customColors.neutral90,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: customColors.neutral90,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: customColors.neutral90,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    const int tickCount = 5;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchAnswerAnalysis(answerText, readingText, activityType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Padding(padding: const EdgeInsets.all(16.0), child: _buildLoadingShimmer(context, customColors)),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox(height: 300, child: Center(child: Text("오류가 발생했습니다.")));
          }
          final analysis = snapshot.data!;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("결과", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 36),
                          radarchart(customColors, tickCount, context, analysis),
                          const SizedBox(height: 16),
                          _buildInfoBox(context, "AI 피드백", analysis["feedback"] ?? "", customColors),
                          const SizedBox(height: 16),
                          _buildInfoBox(context, "모범답안", analysis["modelAnswer"] ?? "", customColors),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  AlertSectionButton(customColors: customColors),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer용 클리퍼
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
