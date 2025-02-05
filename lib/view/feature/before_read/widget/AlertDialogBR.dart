/// File: AlertDialogBR.dart
/// Purpose: 사용자의 학습 결과를 시각적으로 표시하는 알림 다이얼로그 (레이더 차트, AI 피드백 포함)
/// Author: 박민준
/// Created: 2025-01-0?
/// Last Modified: 2025-02-05 by 박민준

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
        child: SingleChildScrollView( // 스크롤 가능하도록 설정
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                Text(
                  "결과",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),


                // 레이더 차트 (플레이스홀더)
                SizedBox(
                  width: 250,
                  height: 180,
                  child: SizedBox(
                    width: 250,
                    height: 200,
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
                            entryRadius: 4,  // 각 끝에 원형 추가
                            borderWidth: 3,
                          ),
                        ],
                        radarBackgroundColor: tickCount % 2 == 1 ? customColors.neutral100 : customColors.neutral80,
                        borderData: FlBorderData(show: false),
                        tickCount: tickCount,
                        titleTextStyle: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
                        getTitle: (index, _) {
                          const titles = ['표현력', '구성력', '논리력'];
                          return RadarChartTitle(text: titles[index]);
                        },
                      ),
                    ),
                  ),
                ),
                // AI 피드백
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "AI 피드백",
                          style: body_small_semi(context)
                      ),
                      const SizedBox(height: 8),
                      Text(
                          "단어 선택이 매우 정확해요! 핵심 단어 2가지를 모두 포함시켰어요.",
                          style: body_small(context)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 다른 유저의 글
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "다른 유저의 답",
                          style: body_small_semi(context)
                      ),
                      const SizedBox(height: 8),
                      Text(
                          "읽기의 기술: 맞춤형 도구와 피드백으로 성장하기",
                          style: body_small(context)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 버튼 섹션
                AlertSectionButtonBr(customColors: customColors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
