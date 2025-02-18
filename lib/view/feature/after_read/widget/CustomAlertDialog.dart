// CustomAlertDialog.dart
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
  final String activityType; // 활동 종류 (예: "요약하기", "결말 바꾸기" 등)

  const CustomAlertDialog({
    Key? key,
    required this.answerText,
    required this.readingText,
    required this.activityType,
  }) : super(key: key);

  // API 호출 실패 시 기본 응답 값
  static const Map<String, dynamic> defaultAnalysisResponse = {
    "expression": 3,
    "logic": 3,
    "composition": 3,
    "feedback": "정보 없음",
    "modelAnswer": "정보 없음",
  };

  // ChatGPT API 호출: answerText, readingText, activityType에 따른 평가 및 피드백 요청
  Future<Map<String, dynamic>> fetchAnswerAnalysis(
      String answerText, String readingText, String activityType) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return defaultAnalysisResponse;

    const endpoint = 'https://api.openai.com/v1/chat/completions';
    final url = Uri.parse(endpoint);

    // 활동 유형에 따른 평가 상황 설명 (프롬프트 내 동적 구성)
    String evaluationContext;
    switch (activityType) {
      case '요약하기':
        evaluationContext = '학생이 주어진 텍스트를 요약하는 활동';
        break;
      case '결말 바꾸기':
        evaluationContext = '학생이 텍스트의 결말을 창의적으로 바꾸는 활동';
        break;
      case '에세이 작성':
        evaluationContext = '학생이 에세이를 작성하는 활동';
        break;
      case '형식 변환 연습':
        evaluationContext = '학생이 텍스트 형식을 변환하는 활동';
        break;
      case '표지 보고 유추하기':
        evaluationContext = '학생이 책 표지를 보고 내용을 유추하는 활동';
        break;
      default:
        evaluationContext = '학생의 활동';
    }

    // 프롬프트는 레이더 차트(표현력, 논리력, 구성력)는 그대로 평가하고,
    // AI 피드백과 모범답안은 해당 활동에 맞는 기준으로 작성하도록 지시합니다.
    final String prompt =
        '당신은 $evaluationContext 을 평가하는 전문가입니다. '
        '학생이 작성한 답변("$answerText")과 원문("$readingText")을 바탕으로, '
        '표현력, 논리력, 구성력을 각각 1부터 5까지의 점수로 평가하세요. '
        '또한, 해당 활동에 적합한 AI 피드백과 모범답안을 제공하세요. '
        '반드시 아래 JSON 형식으로만 응답하세요. '
        'JSON의 키는 "expression", "logic", "composition", "feedback", "modelAnswer"여야 하며, '
        '불필요한 텍스트를 포함하지 마세요. '
        '모든 답변은 한국어로 제공하세요.';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': prompt,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.2,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody =
        jsonDecode(utf8.decode(response.bodyBytes));
        final String message = resBody["choices"][0]["message"]["content"];
        try {
          return jsonDecode(message);
        } catch (e) {
          print("분석 결과 파싱 실패: $e");
          return defaultAnalysisResponse;
        }
      } else {
        print("ChatGPT API 호출 실패: ${response.statusCode} ${response.body}");
        return defaultAnalysisResponse;
      }
    } catch (e) {
      print("Exception in fetchAnswerAnalysis: $e");
      return defaultAnalysisResponse;
    }
  }

  // 레이더 차트 위젯 (표현력, 논리력, 구성력 고정)
  Widget radarchart(CustomColors customColors, int tickCount, BuildContext context,
      Map<String, dynamic> analysis) {
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
            const titles = ['표현력', '구성력', '논리력'];
            return RadarChartTitle(text: titles[index]);
          },
        ),
      ),
    );
  }

  // 정보 박스 위젯 (AI 피드백, 모범답안)
  Widget _buildInfoBox(
      BuildContext context, String title, String content, CustomColors customColors) {
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
          Text(content, style: body_small(context)),
        ],
      ),
    );
  }

  // Shimmer 로딩 UI: 제목, 레이더 차트, AI 피드백, 모범답안 자리 표시
  Widget _buildLoadingShimmer(BuildContext context, CustomColors customColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
      children: [
        // 제목 Shimmer (여기서는 텍스트 "결과"를 그대로 표시)
        Text("결과",
            style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        // 레이더 차트 Shimmer
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
        // AI 피드백 Shimmer
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
        // 모범답안 Shimmer
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchAnswerAnalysis(answerText, readingText, activityType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLoadingShimmer(context, customColors),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 300,
              child: Center(child: Text("오류가 발생했습니다.")),
            );
          }
          final analysis = snapshot.data!;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목 영역
                  Text("결과",
                      style:
                      body_small_semi(context).copyWith(color: customColors.neutral30)),
                  const SizedBox(height: 8),
                  // 스크롤 가능한 콘텐츠 영역
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 36),
                          // 레이더 차트 (표현력, 구성력, 논리력)
                          radarchart(customColors, tickCount, context, analysis),
                          const SizedBox(height: 16),
                          // AI 피드백 영역
                          _buildInfoBox(context, "AI 피드백", analysis["feedback"], customColors),
                          const SizedBox(height: 16),
                          // 모범답안 영역
                          _buildInfoBox(context, "모범답안", analysis["modelAnswer"], customColors),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // 고정 버튼 영역
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
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // 정삼각형(위쪽이 꼭짓점) 형태로 클리핑
    path.moveTo(size.width / 2, 0);       // 꼭짓점 (상단 중앙)
    path.lineTo(0, size.height);          // 좌측 하단
    path.lineTo(size.width, size.height); // 우측 하단
    path.close();                       // 경로 닫기
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
