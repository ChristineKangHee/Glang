/// File: choose_activities.dart
/// Purpose: 읽기후 학습선택하는 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';

import '../../components/custom_button.dart';
import '../Result_Report.dart';
import 'GA_03_01_change_ending/CE_main.dart';
import 'GA_03_02_content_summary/CS_main.dart';
import 'GA_03_03_debate_activity/DA_main.dart';
import 'GA_03_04_diagram/diagram_learning.dart';
import 'GA_03_04_diagram/diagram_main.dart';
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
    int completedCount = activities.where((activity) => activity.isCompleted).length;

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_6(
        title: '학습 선택',
        automaticallyImplyLeading: false,
        onIconPressed: () {
          Navigator.pushNamed(context, '/');
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    LearningProgress(completedCount, customColors, context),
                    const SizedBox(height: 20),
                    ActivityList(context, customColors),
                  ],
                ),
              ),
            ),
          ),
          ResultButton(context, completedCount, customColors),
        ],
      ),
    );
  }

  // 학습 결과 확인 버튼
  Widget ResultButton(BuildContext context, int completedCount, CustomColors customColors) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: completedCount / activities.length < 1.0
          ? ButtonPrimary20(
        function: () {
          print("학습 결과 확인하기");
        },
        title: '학습 결과 확인하기',
      )
          : ButtonPrimary(
        function: () {
          print("학습 결과 확인하기");
          _showResultDialog(context, customColors);
        },
        title: '학습 결과 확인하기',
      ),
    );
  }

  // 결과 팝업
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
              children: [
                Text(
                  '결과를 확인하시겠습니까?',
                  style: body_small_semi(context).copyWith(color: customColors.neutral30),
                ),
                const SizedBox(height: 20),
                _buildDialogButtons(context, customColors),
              ],
            ),
          ),
        );
      },
    );
  }

  // 팝업 버튼
  Widget _buildDialogButtons(BuildContext context, CustomColors customColors) {
    return Row(
      children: [
        _buildDialogButton(context, '아니오', customColors.neutral90!, customColors.neutral60!, () {
          Navigator.pop(context);
        }),
        const SizedBox(width: 16),
        _buildDialogButton(context, '네', customColors.primary!, customColors.neutral100!, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResultReportPage()),
          );
        }),
      ],
    );
  }

  // 팝업 버튼 생성
  Widget _buildDialogButton(BuildContext context, String title, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  // 학습 진행 상황
  Widget LearningProgress(int completedCount, CustomColors customColors, BuildContext context) {
    int totalXP = activities.where((activity) => activity.isCompleted).map((activity) => int.parse(activity.xp.replaceAll('xp', ''))).fold(0, (prev, element) => prev + element);
    int totalPossibleXP = activities.map((activity) => int.parse(activity.xp.replaceAll('xp', ''))).fold(0, (prev, element) => prev + element);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 10.0,
            animation: true,
            percent: completedCount / activities.length,
            center: Text('${(completedCount / activities.length * 100).toStringAsFixed(0)}%', style: body_xsmall_semi(context).copyWith(color: customColors.neutral30)),
            progressColor: customColors.primary,
            backgroundColor: customColors.neutral80 ?? Colors.grey,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          _buildProgressText(totalXP, totalPossibleXP, completedCount, customColors),
        ],
      ),
    );
  }

  // 학습 진행 텍스트
  Widget _buildProgressText(int totalXP, int totalPossibleXP, int completedCount, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$totalXP/$totalPossibleXP xp', style: heading_medium(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        Text('$completedCount/${activities.length} 학습 완료', style: body_xsmall(context).copyWith(color: customColors.neutral60)),
      ],
    );
  }

  // 학습 활동 목록
  Widget ActivityList(BuildContext context, CustomColors customColors) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('학습 활동', style: body_small_semi(context)),
          const SizedBox(height: 20),
          ...sortedActivities.map((activity) => _buildActivityItem(context, activity, customColors)),
        ],
      ),
    );
  }

  // 학습 항목
  Widget _buildActivityItem(BuildContext context, LearningActivity activity, CustomColors customColors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: activity.isCompleted ? customColors.neutral90 : customColors.neutral100,
          shape: RoundedRectangleBorder(
            side: activity.isCompleted ? BorderSide.none : BorderSide(width: 1, color: customColors.neutral80 ?? Color(0xFFCDCED3)),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActivityText(activity, customColors),
            _buildActivityButton(context, activity, customColors),
          ],
        ),
      ),
    );
  }

  // 학습 항목 텍스트
  Widget _buildActivityText(LearningActivity activity, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity.title, style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        if (!activity.isCompleted)
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: customColors.neutral30),
              const SizedBox(width: 4),
              Text(activity.time, style: body_xsmall(context).copyWith(color: customColors.neutral30)),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: customColors.neutral30),
              const SizedBox(width: 4),
              Text(activity.xp, style: body_xsmall(context).copyWith(color: customColors.neutral30)),
            ],
          )
        else
          Text('경험치 ${activity.xp} 획득!', style: body_xsmall(context).copyWith(color: customColors.primary)),
      ],
    );
  }

  // 학습하기 버튼
  Widget _buildActivityButton(BuildContext context, LearningActivity activity, CustomColors customColors) {
    return ElevatedButton(
      onPressed: activity.isCompleted
          ? null
          : () {
        setState(() {
          activity.isCompleted = true;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => _getActivityPage(activity.title)));
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        backgroundColor: activity.isCompleted ? customColors.neutral80 : customColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        activity.isCompleted ? '학습완료' : '학습하기',
        style: body_xsmall_semi(context).copyWith(color: activity.isCompleted ? customColors.neutral30 : customColors.neutral100),
      ),
    );
  }

  // 학습 활동에 맞는 페이지 반환
  Widget _getActivityPage(String title) {
    switch (title) {
    case '결말 바꾸기':
    return ChangeEndingMain();
    case '에세이 작성':
    return WritingEssayMain();
    case '형식 변환하기':
    return FormatConversionMain();
    case '요약하기':
    return ContentSummaryMain();
    case '토론':
    return DebateActivityMain();
    case '다이어그램':
    return DiagramMain();
    case '문장 구조':
    return WritingFormMain();
    case '주제 추출':
    return ParagraphAnalysisMain();
    case '자유 소감':
    return ReviewWritingMain();
      default:
        return SizedBox();
    }
  }
}
