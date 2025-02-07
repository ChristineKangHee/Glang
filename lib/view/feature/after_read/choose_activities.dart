/// File: choose_activities.dart
/// Purpose: 읽기 후 학습 선택 화면 (Firestore의 stage 데이터에 따라 진행할 feature만 표시)
/// Author: 강희 (수정됨)
/// Created: 2024-1-19
/// Last Modified: 2025-02-07 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../model/section_data.dart';
import '../../../model/stage_data.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import '../../components/custom_button.dart';
import '../../home/stage_provider.dart';
import '../Result_Report.dart';
import 'GA_03_01_change_ending/CE_main.dart';
import 'GA_03_02_content_summary/CS_learning.dart';
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

/// 학습 활동 데이터 모델
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
  // 전체 학습 활동 리스트 (인덱스+1을 feature 번호로 가정)
  final List<LearningActivity> activities = [
    LearningActivity(title: '결말 바꾸기', time: '20분', xp: '100xp'),
    LearningActivity(title: '요약', time: '10분', xp: '50xp'),
    LearningActivity(title: '토론', time: '25분', xp: '120xp'),
    LearningActivity(title: '다이어그램', time: '5분', xp: '10xp'),
    LearningActivity(title: '문장 구조', time: '5분', xp: '10xp'),
    LearningActivity(title: '에세이 작성', time: '15분', xp: '80xp'),
    LearningActivity(title: '형식 변환하기', time: '30분', xp: '150xp'),
    LearningActivity(title: '주제 추출', time: '5분', xp: '10xp'),
    LearningActivity(title: '자유 소감', time: '5분', xp: '10xp'),
  ];

  // Firestore에서 로드한 StageData를 저장할 Future
  Future<StageData?>? _stageDataFuture;

  @override
  void initState() {
    super.initState();

    // 기존 설명 팝업 (원래 코드 유지)
    Future.delayed(Duration(seconds: 0), () {
      _showExplanationPopup();
    });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);  // 팝업 닫기
    });

    // Firebase에서 userId와 stageId 읽기 (각 provider에서 가져옴)
    final userId = ref.read(userIdProvider);
    final stageId = ref.read(selectedStageIdProvider);
    _stageDataFuture = _loadStageData(userId!, stageId!);
  }

  /// Firestore에서 현재 스테이지 데이터를 불러오는 함수
  Future<StageData?> _loadStageData(String userId, String stageId) async {
    final stages = await loadStagesFromFirestore(userId);
    try {
      return stages.firstWhere((stage) => stage.stageId == stageId);
    } catch (e) {
      print('Stage $stageId not found: $e');
      return null;
    }
  }

  // 설명 팝업 표시 함수
  void _showExplanationPopup() {
    final customColors = ref.read(customColorsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 28),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '읽은 내용과 관련된\n미션을 해볼까요?',
                          textAlign: TextAlign.center,
                          style: body_large_semi(context).copyWith(color: customColors.neutral30),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: 172,
                        height: 172,
                        child: Image.asset("assets/images/book_star.png"),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '경험치를 채워 미션을 완료해보세요!',
                          textAlign: TextAlign.center,
                          style: body_small(context).copyWith(color: customColors.neutral60),
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

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);

    return FutureBuilder<StageData?>(
      future: _stageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: customColors.neutral90,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: customColors.neutral90,
            body: Center(child: Text("Stage 데이터를 불러올 수 없습니다.", style: body_small(context))),
          );
        }

        final stageData = snapshot.data!;
        // arData.features에 포함된 feature 번호(예: [2,3,4])만 사용
        final allowedFeatures = stageData.arData?.features;

        // activities 리스트의 인덱스+1이 allowedFeatures에 포함된 경우에만 화면에 표시
        final availableActivities = <LearningActivity>[];
        for (int i = 0; i < activities.length; i++) {
          if (allowedFeatures!.contains(i + 1)) {
            availableActivities.add(activities[i]);
          }
        }
        // 완료된 활동 수 계산 (availableActivities만 사용)
        final completedCount = availableActivities.where((activity) => activity.isCompleted).length;

        return Scaffold(
          backgroundColor: customColors.neutral90,
          appBar: CustomAppBar_2depth_6(
            title: '미션 선택',
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
                        LearningProgress(completedCount, customColors, context, availableActivities),
                        const SizedBox(height: 20),
                        ActivityList(context, customColors, availableActivities),
                      ],
                    ),
                  ),
                ),
              ),
              ResultButton(context, completedCount, customColors, availableActivities),
            ],
          ),
        );
      },
    );
  }

  // 학습 결과 확인 버튼
  Widget ResultButton(BuildContext context, int completedCount, CustomColors customColors, List<LearningActivity> availableActivities) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: completedCount / availableActivities.length < 1.0
          ? ButtonPrimary20(
        function: () {
          print("결과 확인하기");
        },
        title: '결과 확인하기',
      )
          : ButtonPrimary(
        function: () {
          print("결과 확인하기");
          showResultDialog(
            context,
            customColors,
            "결과를 확인하시겠습니까?",
            "아니오",
            "예",
                (ctx) {
              Navigator.pushReplacement(
                ctx,
                MaterialPageRoute(builder: (ctx) => ResultReportPage()),
              );
            },
          );
        },
        title: '결과 확인하기',
      ),
    );
  }

  // 학습 진행 상황
  Widget LearningProgress(int completedCount, CustomColors customColors, BuildContext context, List<LearningActivity> availableActivities) {
    int totalXP = availableActivities
        .where((activity) => activity.isCompleted)
        .map((activity) => int.parse(activity.xp.replaceAll('xp', '')))
        .fold(0, (prev, element) => prev + element);
    int totalPossibleXP = availableActivities
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
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 10.0,
            animation: true,
            percent: availableActivities.isEmpty ? 0 : completedCount / availableActivities.length,
            center: Text('${(availableActivities.isEmpty ? 0 : (completedCount / availableActivities.length * 100)).toStringAsFixed(0)}%', style: body_xsmall_semi(context).copyWith(color: customColors.neutral30)),
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
        Text('$completedCount 미션 완료', style: body_xsmall(context).copyWith(color: customColors.neutral60)),
      ],
    );
  }

  // 학습 활동 목록
  Widget ActivityList(BuildContext context, CustomColors customColors, List<LearningActivity> availableActivities) {
    final sortedActivities = List<LearningActivity>.from(availableActivities)
      ..sort((a, b) => a.isCompleted ? 1 : -1);

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
          Text('미션', style: body_small_semi(context)),
          const SizedBox(height: 20),
          ...sortedActivities.map((activity) => _buildActivityItem(context, activity, customColors)),
        ],
      ),
    );
  }

  // 개별 학습 항목
  Widget _buildActivityItem(BuildContext context, LearningActivity activity, CustomColors customColors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: activity.isCompleted ? customColors.neutral90 : customColors.neutral100,
          shape: RoundedRectangleBorder(
            side: activity.isCompleted ? BorderSide.none : BorderSide(width: 1, color: customColors.neutral80 ?? const Color(0xFFCDCED3)),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _getActivityPage(activity.title)),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        backgroundColor: activity.isCompleted ? customColors.neutral80 : customColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        activity.isCompleted ? '미션완료' : '미션하기',
        style: body_xsmall_semi(context).copyWith(color: activity.isCompleted ? customColors.neutral30 : customColors.neutral100),
      ),
    );
  }

  // 학습 활동에 맞는 페이지 반환
  Widget _getActivityPage(String title) {
    switch (title) {
      case '결말 바꾸기':
        return ChangeEndingMain();
      case '요약':
        return CSLearning();
      case '토론':
        return DebateActivityMain();
      case '다이어그램':
        return RootedTreeScreen();
      case '문장 구조':
        return WritingFormMain();
      case '에세이 작성':
        return WritingEssayMain();
      case '형식 변환하기':
        return FormatConversionMain();
      case '주제 추출':
        return ParagraphAnalysisMain();
      case '자유 소감':
        return ReviewWritingMain();
      default:
        return const SizedBox();
    }
  }
}
