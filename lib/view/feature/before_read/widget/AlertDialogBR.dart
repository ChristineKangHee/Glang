// File: AlertDialogBR.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:shimmer/shimmer.dart';
import '../../after_read/widget/CustomAlertDialog.dart'; // TriangleClipper 사용
import 'alert_section_button_br.dart';

class AlertDialogBR extends StatelessWidget {
  final String answerText;
  final String coverImageUrl;
  final List<String> keywords;

  const AlertDialogBR({
    Key? key,
    required this.answerText,
    required this.coverImageUrl,
    required this.keywords,
  }) : super(key: key);

  // 점수 엄격도(1=온건, 2=보통, 3=엄격)
  static const int strictness = 2;

  // 기본값(파싱/네트워크 실패 대비)
  static const Map<String, dynamic> defaultAnalysisResponse = {
    "expression": 3,
    "logic": 3,
    "composition": 3,
    "feedback": "정보 없음",
    "modelAnswer": "정보 없음",
  };

  // ──────────────── 유틸/로깅 ────────────────
  void _log(String tag, Object msg) {
    final s = msg.toString();
    final cut = s.length > 1200 ? (s.substring(0, 1200) + '…') : s;
    // ignore: avoid_print
    print('[BR][$tag] $cut');
  }

  bool _lenOk(dynamic v, int minChars) {
    final s = (v ?? '').toString().trim();
    return s.length >= minChars;
  }

  Map<String, dynamic> _postValidate(Map<String, dynamic> m) {
    int clamp(num v) => v < 1 ? 1 : (v > 5 ? 5 : v.round());
    return {
      "expression": clamp(m["expression"] ?? 3),
      "logic": clamp(m["logic"] ?? 3),
      "composition": clamp(m["composition"] ?? 3),
      "feedback": (m["feedback"] ?? "").toString(),
      "modelAnswer": (m["modelAnswer"] ?? "").toString(),
    };
  }

  // ──────────────── 텍스트 휴리스틱 ────────────────
  Set<String> _tokenize(String s) {
    final cleaned = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9가-힣\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return <String>{};
    return cleaned.split(' ').where((t) => t.length >= 2).toSet();
  }

  int _countSentences(String s) {
    final reg = RegExp(r'[\.!\?…。！？]+');
    final parts = s.split(reg).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.length;
  }

  bool _hasReasonMarker(String s) {
    const markers = [
      '왜냐', '때문', '그래서', '따라서', '근거', '단서', '바탕으로', '보아', '추론', '추정', '연상', '관련'
    ];
    return markers.any((m) => s.contains(m));
  }

  int _countKeywordOverlap(Set<String> answerTokens, List<String> keywords) {
    if (keywords.isEmpty) return 0;
    int c = 0;
    for (final k in keywords) {
      final t = k.toLowerCase().trim();
      if (t.isEmpty) continue;
      // 키워드가 공백 포함일 수 있으니 토큰 단위/부분 문자열 둘 다 체크
      if (answerTokens.contains(t) || t.split(' ').any((w) => w.length > 1 && answerTokens.contains(w))) {
        c++;
      }
    }
    return c;
  }

  // ──────────────── 점수 재산출(모델 점수 무시) ────────────────
  Map<String, dynamic> _recomputeScores({
    required Map<String, dynamic> modelOut,   // 모델이 준 JSON(피드백/모범답안은 사용)
    required String answerText,
    required List<String> keywords,
    required int strictness,
  }) {
    int clamp(int v) => v < 1 ? 1 : (v > 5 ? 5 : v);

    final ans = answerText.trim();
    final toks = _tokenize(ans);
    final sent = _countSentences(ans);
    final len = ans.length;
    final overlap = _countKeywordOverlap(toks, keywords);
    final hasReason = _hasReasonMarker(ans);

    // 어휘 다양성(고유/전체) — 너무 낮으면 표현력 감점
    final uniqRatio = toks.isEmpty ? 0.0 : (toks.length / (ans.split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).length));
    // 구성 적정 길이/문장 수
    final lengthOK = len >= 80 && len <= 500;
    final sentenceOK = sent >= 2 && sent <= 8;

    // 기본 3점에서 시작
    int exp = 3, logi = 3, comp = 3;

    // 표현력: 문장수/어휘다양성/길이 기반
    if (sentenceOK) exp++;
    if (uniqRatio >= 0.5) exp++;
    if (len < 60) exp--;
    if (len >= 140) exp++;  // 충분한 전개 가점
    exp = clamp(exp);

    // 논리력: 키워드 사용 + 이유 제시 + 길이
    if (overlap >= 2) logi++;
    if (overlap == 0) logi -= 2;
    if (hasReason) logi++; else logi--;
    if (len < 60) logi--;
    logi = clamp(logi);

    // 구성력: 시작-전개-정리 느낌(문장수), 과/소장황 페널티
    if (sentenceOK) comp++;
    if (sent < 2 || sent > 10) comp--;
    if (!lengthOK) comp--;
    comp = clamp(comp);

    // 활동 특성(표지 탐구): 키워드 연결과 추론 표현이 핵심
    if (overlap < 1) { logi = clamp(logi - 1); }
    if (!hasReason) { comp = clamp(comp - 1); }

    // 엄격도 조정
    if (strictness == 3) {
      if (overlap < 2) logi = clamp(logi - 1);
      if (!sentenceOK) { exp = clamp(exp - 1); comp = clamp(comp - 1); }
    } else if (strictness == 1) {
      if (exp < 2) exp = 2;
      if (logi < 2) logi = 2;
      if (comp < 2) comp = 2;
    }

    // 5점 상한(완벽할 때만 5 허용)
    final perfect = overlap >= 2 && hasReason && sentenceOK && lengthOK && uniqRatio >= 0.5;
    if (!perfect) {
      if (exp == 5) exp = 4;
      if (logi == 5) logi = 4;
      if (comp == 5) comp = 4;
    }

    // 모델이 준 텍스트는 그대로 사용
    return {
      "expression": exp,
      "logic": logi,
      "composition": comp,
      "feedback": (modelOut["feedback"] ?? "").toString(),
      "modelAnswer": (modelOut["modelAnswer"] ?? "").toString(),
    };
  }

  // ──────────────── 모델 호출(가볍게) ────────────────

  // Chat Completions(JSON 모드) 1차 호출
  Future<Map<String, dynamic>> _callOnce({
    required String apiKey,
    required String model,
    required String answerText,
    required String coverImageUrl,
    required List<String> keywords,
  }) async {
    final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final kw = keywords.join(', ');

    final sys = '''
너는 초중등 '표지 탐구하기' 활동 평가자다. 반드시 한국어로만 답하라.
이미지 URL은 접근 불가할 수 있으니, 접근이 어렵다면 **키워드**와 학생 답변을 중심으로 평가하라.
아래 JSON 키만 포함하여 응답하라(텍스트 외 문자는 금지):
{"expression":(1~5 정수),"logic":(1~5 정수),"composition":(1~5 정수),"feedback":"문장","modelAnswer":"문장"}''';

    final user = '''
[표지 정보]
- 이미지 URL: $coverImageUrl
- 키워드: $kw

[학생 답변]
$answerText

[지시]
- 표현력(expression), 논리력(logic), 구성력(composition): 각 1~5의 정수
- feedback: 학생이 고칠 점을 2~3문장으로 간단히 제시(최소 50자)
- modelAnswer: 표지와 키워드를 근거로 한 "가능한 제목 + 간단 근거" 1~2문장
- 오직 JSON 객체만 출력''';

    final payload = {
      'model': model, // gpt-4.1-mini 권장
      'messages': [
        {'role': 'system', 'content': sys},
        {'role': 'user', 'content': user},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.3,
      'max_tokens': 700,
    };

    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      _log('chat.error', resp.body);
      return defaultAnalysisResponse;
    }

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final raw = (data['choices'][0]['message']['content'] ?? '').toString();
    _log('chat.raw', raw);
    try {
      return _postValidate(jsonDecode(raw));
    } catch (e) {
      _log('chat.parse.fail', e);
      return defaultAnalysisResponse;
    }
  }

  // feedback/modelAnswer가 짧거나 비면, 텍스트만 재생성
  Future<Map<String, String>> _refillTextOnly({
    required String apiKey,
    required String model,
    required String coverImageUrl,
    required List<String> keywords,
    required String answerText,
    required int minFb,
    required int minMa,
  }) async {
    final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final kw = keywords.join(', ');

    final sys = '''
아래 JSON만 출력:
{"feedback":"${minFb}자 이상","modelAnswer":"${minMa}자 이상 가능하면 1~2문장"}
반드시 한국어.''';

    final user = '''
[표지 정보]
- 이미지 URL: $coverImageUrl
- 키워드: $kw

[학생 답변]
$answerText

[지시]
- 키워드/학생 답변에 근거한 구체적 피드백과 가능한 제목+근거를 작성
- 오직 JSON 객체만 출력''';

    final payload = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': sys},
        {'role': 'user', 'content': user},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.3,
      'max_tokens': 600,
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
      final parsed = jsonDecode(raw);
      return {
        "feedback": (parsed["feedback"] ?? "").toString(),
        "modelAnswer": (parsed["modelAnswer"] ?? "").toString(),
      };
    } catch (e) {
      _log('chat.refill.exception', e);
      return {};
    }
  }

  /// 가볍게: 1) JSON 모드 호출 → 2) 짧으면 텍스트만 보정 → 3) 점수 재계산(휴리스틱)
  Future<Map<String, dynamic>> fetchAnswerAnalysis() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return defaultAnalysisResponse;

    const model = 'gpt-4o'; // 가볍고 안정적. 필요시 gpt-4o-mini로 변경 가능.
    const minFb = 50;  // 피드백 최소길이
    const minMa = 30;  // 모범답안 최소길이(짧게 유지)

    try {
      // 1) 모델 호출
      var first = await _callOnce(
        apiKey: apiKey,
        model: model,
        answerText: answerText,
        coverImageUrl: coverImageUrl,
        keywords: keywords,
      );

      // 2) 텍스트가 짧으면 보정
      if (!_lenOk(first['feedback'], minFb) || !_lenOk(first['modelAnswer'], minMa)) {
        final fill = await _refillTextOnly(
          apiKey: apiKey,
          model: model,
          coverImageUrl: coverImageUrl,
          keywords: keywords,
          answerText: answerText,
          minFb: minFb,
          minMa: minMa,
        );
        if ((fill['feedback'] ?? '').isNotEmpty) first['feedback'] = fill['feedback'];
        if ((fill['modelAnswer'] ?? '').isNotEmpty) first['modelAnswer'] = fill['modelAnswer'];
      }

      // 3) 점수 재계산(모델 점수 무시 → 휴리스틱으로 최종 산출)
      final finalOut = _recomputeScores(
        modelOut: first,
        answerText: answerText,
        keywords: keywords,
        strictness: strictness,
      );

      return _postValidate(finalOut);
    } catch (e) {
      _log('fetch.exception', e);
      return defaultAnalysisResponse;
    }
  }

  /// 레이더 차트 (표현력, 논리력, 구성력)
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

  /// 정보 박스 (AI 피드백, 모범답안)
  Widget _buildInfoBox(
      BuildContext context, String title, String content, CustomColors customColors) {
    final text = (content.trim().isEmpty) ? '정보 없음' : content;
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
          Text(text, style: body_small(context)),
        ],
      ),
    );
  }

  /// Shimmer 로딩 UI
  Widget _buildLoadingShimmer(BuildContext context, CustomColors customColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("결과", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(width: 130, height: 100, color: customColors.neutral90),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: customColors.neutral90, borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: customColors.neutral90, borderRadius: BorderRadius.circular(12.0)),
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
        future: fetchAnswerAnalysis(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLoadingShimmer(context, customColors),
              ),
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
                        ],
                      ),
                    ),
                  ),
                  AlertSectionButtonBr(customColors: customColors),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
