import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'alert_section_button.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final int tickCount = 5; // Example, replace with actual tickCount value

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Text(
                "결과",
                style: body_small_semi(context).copyWith(color: customColors.neutral30),
              ),
              const SizedBox(height: 8),
              // 스크롤 가능 영역
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
                          _buildInfoBox(context, "AI 피드백", "단어 선택이 매우 정확해요! 핵심 단어 2가지를 모두 포함시켰어요. 하지만 단어의 순서가 달라요. 그래도 잘 하셨어요!"),
                          const SizedBox(height: 16),

                          // 다른 유저의 글
                          _buildInfoBox(context, "다른 유저의 글", "다람쥐는 작은 토끼를 보고 미소 지으며 말했어요. ‘내가 집까지 데려다줄게!’ 작은 토끼는 다람쥐의 도움으로 무사히 집으로 돌아왔어요."),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Dimmed overlay with text
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
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
              AlertSectionButton(customColors: customColors),
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

  Widget _buildInfoBox(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
