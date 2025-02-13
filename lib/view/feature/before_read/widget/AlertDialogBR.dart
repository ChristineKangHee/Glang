import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'alert_section_button_br.dart';
import 'package:fl_chart/fl_chart.dart';

class AlertDialogBR extends StatelessWidget {
  const AlertDialogBR({super.key});
  final int tickCount = 5; // Example, replace with actual tickCount value

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 최대 높이 제한
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              Text(
                "결과",
                style: body_small_semi(context).copyWith(color: customColors.neutral30),
              ),
              const SizedBox(height: 8),

              // 스크롤 가능한 영역
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 36),
                          // 레이더 차트
                          radarchart(customColors, tickCount, context),
                          const SizedBox(height: 16),

                          // AI 피드백
                          _buildInfoBox(context, "AI 피드백", "단어 선택이 매우 정확해요! 핵심 단어 2가지를 모두 포함시켰어요.", customColors),
                          const SizedBox(height: 16),

                          // 다른 유저의 글
                          _buildInfoBox(context, "다른 유저의 답", "읽기의 기술: 맞춤형 도구와 피드백으로 성장하기", customColors),
                        ],
                      ),
                    ),
                    // Dimmed overlay with text
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4), // Dims everything underneath
                        child: Center(
                          child: Text(
                            "곧 출시할 예정입니다",
                            style: body_large_semi(context).copyWith(color: customColors.neutral100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 고정 버튼 영역
              AlertSectionButtonBr(customColors: customColors),
            ],
          ),
        ),
      ),
    );
  }


  Widget radarchart(CustomColors customColors, int tickCount, BuildContext context) {
    return Container(
      child: SizedBox(
        width: 250,
        height: 170,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            titlePositionPercentageOffset: 0.2,
            dataSets: [
              RadarDataSet(
                dataEntries: [
                  RadarEntry(value: 4),
                  RadarEntry(value: 3),
                  RadarEntry(value: 5),
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
            ticksTextStyle: TextStyle(color: Colors.transparent), // 숫자 제거
            titleTextStyle: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
            getTitle: (index, _) {
              const titles = ['표현력', '구성력', '논리력'];
              return RadarChartTitle(text: titles[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, String title, String content, CustomColors customColors) {
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
}
