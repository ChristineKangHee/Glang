import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:readventure/view/feature/after_read/GA_03_04_diagram/diagram_main.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';

import '../../components/custom_button.dart';
import 'GA_03_01_change_ending/CE_main.dart';
import 'GA_03_02_content_summary/CS_main.dart';
import 'GA_03_04_diagram/diagram_learning.dart';
import 'GA_03_05_writing_form/writing_form_main.dart';
import 'GA_03_06_writing_essay/WE_main.dart';
import 'GA_03_07_format_conversion/FC_main.dart';
import 'GA_03_08_paragraph_analysis/paragraph_analysis.dart';
import 'GA_03_08_paragraph_analysis/paragraph_analysis_main.dart';
import 'GA_03_09_review_writing/review_writing.dart';
import 'GA_03_09_review_writing/review_writing_main.dart';

// 학습 활동 데이터 모델
class LearningActivity {
  final String title;
  final String time;
  final String xp;
  bool isCompleted;

  LearningActivity({
    required this.title,
    required this.time,
    required this.xp,
    this.isCompleted = false,
  });
}

class LearningActivitiesPage extends ConsumerStatefulWidget {
  @override
  _LearningActivitiesPageState createState() => _LearningActivitiesPageState();
}

class _LearningActivitiesPageState extends ConsumerState<LearningActivitiesPage> {
  // 학습 활동 목록
  final List<LearningActivity> activities = [
    LearningActivity(title: '결말 바꾸기', time: '20분', xp: '100xp'),
    LearningActivity(title: '에세이 작성', time: '15분', xp: '80xp'),
    LearningActivity(title: '형식 변환하기', time: '30분', xp: '150xp'),
    LearningActivity(title: '요약하기', time: '10분', xp: '50xp'),
    LearningActivity(title: '토론', time: '25분', xp: '120xp'),
    LearningActivity(title: '다이어그램', time: '5분', xp: '10xp'),
    LearningActivity(title: '문장 구조', time: '5분', xp: '10xp'),
    LearningActivity(title: '주제 추출', time: '5분', xp: '10xp'),
    LearningActivity(title: '자유 소감', time: '5분', xp: '10xp'),
  ];

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);

    // 완료한 학습의 수
    int completedCount = activities.where((activity) => activity.isCompleted).length;

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_6(
        title: '학습 선택',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 학습 상황 카드 추가
                    LearningProgress(completedCount, customColors, context),
                    const SizedBox(height: 20),
                    // 학습 활동 목록
                    ActivityList(context, customColors),
                  ],
                ),
              ),
            ),
          ),
          // 학습 결과 확인 버튼
          ResultButton(context, completedCount, customColors),
        ],
      ),
    );
  }

  Widget ResultButton(BuildContext context, int completedCount, CustomColors customColors) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: completedCount / activities.length < 1.0
          ? ButtonPrimary20(
        function: () {
          print("학습 결과 확인하기"); // 팝업을 띄우는 함수 호출
        },
        title: '학습 결과 확인하기',
      )
          : ButtonPrimary(
        function: () {
          print("학습 결과 확인하기");
          _showResultDialog(context, customColors); // 팝업을 띄우는 함수 호출
        },
        title: '학습 결과 확인하기',
      ),
    );
  }

  void _showResultDialog(BuildContext context, CustomColors customColors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: customColors.neutral100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 팝업 제목
                Container(
                  width: double.infinity,
                  child: Text(
                    '결과를 확인하시겠습니까?',
                    style: body_small_semi(context).copyWith(
                      color: customColors.neutral30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 팝업 버튼들
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 아니오 버튼
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: ShapeDecoration(
                            color: customColors.neutral90,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '아니오',
                                textAlign: TextAlign.center,
                                style: body_small_semi(context).copyWith(
                                  color: customColors.neutral60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 네 버튼
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: ShapeDecoration(
                            color: customColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '네',
                                textAlign: TextAlign.center,
                                style: body_small_semi(context).copyWith(
                                  color: customColors.neutral100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget LearningProgress(int completedCount, CustomColors customColors, BuildContext context) {
    int totalXP = activities
        .where((activity) => activity.isCompleted)
        .map((activity) => int.parse(activity.xp.replaceAll('xp', '')))
        .fold(0, (prev, element) => prev + element);

    int totalPossibleXP = activities
        .map((activity) => int.parse(activity.xp.replaceAll('xp', '')))
        .fold(0, (prev, element) => prev + element);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '학습 상황',
            style: body_small_semi(context).copyWith(
              color: customColors.neutral30,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 10.0,
                animation: true,
                percent: completedCount / activities.length,
                center: Text(
                  '${(completedCount / activities.length * 100).toStringAsFixed(0)}%',
                  style: body_xsmall_semi(context).copyWith(
                    color: customColors.neutral30,
                  ),
                ),
                progressColor: customColors.primary,
                backgroundColor: customColors.neutral80 ?? Colors.grey,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalXP/$totalPossibleXP xp',
                    style: heading_medium(context).copyWith(
                      color: customColors.neutral30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedCount/${activities.length} 학습 완료',
                    style: body_xsmall(context).copyWith(
                      color: customColors.neutral60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ActivityList(BuildContext context, CustomColors customColors) {
    // 완료된 항목은 리스트 하단으로 정렬
    final sortedActivities = activities..sort((a, b) => a.isCompleted ? 1 : -1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Text(
            '학습 활동',
            style: body_small_semi(context),
          ),
          const SizedBox(height: 20),
          Column(
            children: sortedActivities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: ShapeDecoration(
                    color: activity.isCompleted
                        ? customColors.neutral90
                        : customColors.neutral100,
                    shape: RoundedRectangleBorder(
                      side: activity.isCompleted
                          ? BorderSide.none
                          : BorderSide(width: 1, color: customColors.neutral80 ?? Color(0xFFCDCED3)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                        children: [
                          Text(
                            activity.title,
                            style: body_small_semi(context).copyWith(
                              color: customColors.neutral30,
                            ),
                          ),
                          const SizedBox(height: 8,),
                          if (!activity.isCompleted)
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.timer, size: 16, color: customColors.neutral30),
                                    const SizedBox(width: 4),
                                    Text(
                                      activity.time,
                                      style: body_xsmall(context).copyWith(
                                        color: customColors.neutral30,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: customColors.neutral30),
                                    const SizedBox(width: 4),
                                    Text(
                                      activity.xp,
                                      style: body_xsmall(context).copyWith(
                                        color: customColors.neutral30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Text(
                              '경험치 ${activity.xp} 획득!',
                              style: body_xsmall(context).copyWith(
                                color: customColors.primary,
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: activity.isCompleted
                            ? null
                            : () {
                          setState(() {
                            activity.isCompleted = true; // 색상 변화 유지
                          });
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              // 각 활동에 따른 페이지 연결
                              switch (activity.title) {
                                case '결말 바꾸기':
                                  return ChangeEndingMain();
                                case '에세이 작성':
                                  return WritingEssayMain();
                                case '형식 변환하기':
                                  return FormatConversionMain();
                                case '요약하기':
                                  return ContentSummaryMain();
                                case '토론':
                                  return ContentSummaryMain();
                                case '다이어그램':
                                  return DiagramMain();
                                case '문장 구조':
                                  return WritingFormMain();
                                case '주제 추출':
                                  return ParagraphAnalysisMain();
                                case '자유 소감':
                                  return ReviewWritingMain();
                                default:
                                  return LearningActivitiesPage(); // 기본 페이지
                              }
                            },
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activity.isCompleted
                              ? customColors.neutral80
                              : customColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          activity.isCompleted ? '학습완료' : '학습하기',
                          style: body_xsmall(context).copyWith(
                            color: activity.isCompleted
                                ? customColors.neutral30
                                : customColors.neutral100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
