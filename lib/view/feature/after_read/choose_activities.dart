/// File: choose_activities.dart
/// Purpose: 읽기 후 학습 선택 화면 (Firestore의 stage 데이터에 따라 진행할 feature만 표시)
/// Author: 강희 (수정됨)
/// Created: 2024-1-19
/// Last Modified: 2025-02-07 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../model/section_data.dart';
import '../../../model/stage_data.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/section_provider.dart';
import '../../../viewmodel/user_service.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import '../../components/custom_button.dart';
import '../../home/stage_provider.dart';
import '../Result_Report.dart';
import 'GA_03_01_change_ending/CE_main.dart';
import 'GA_03_02_content_summary/CS_learning.dart';
import 'GA_03_02_content_summary/CS_main.dart';
import 'GA_03_03_debate_activity/DA_learning.dart';
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
  final int featureNumber;

  LearningActivity({
    required this.title,
    required this.time,
    required this.xp,
    required this.featureNumber,
    this.isCompleted = false,
  });
}

class LearningActivitiesPage extends ConsumerStatefulWidget {
  @override
  _LearningActivitiesPageState createState() => _LearningActivitiesPageState();
}

class _LearningActivitiesPageState extends ConsumerState<LearningActivitiesPage> {
  // 전체 학습 활동 리스트 (인덱스+1을 feature 번호로 가정)
  // activities 리스트 생성 시 각 미션에 featureNumber를 할당
  final List<LearningActivity> activities = [
    LearningActivity(title: '결말 바꾸기', time: '20분', xp: '100xp', featureNumber: 1),
    LearningActivity(title: '요약', time: '10분', xp: '50xp', featureNumber: 2),
    LearningActivity(title: '토론', time: '25분', xp: '120xp', featureNumber: 3),
    LearningActivity(title: '다이어그램', time: '5분', xp: '10xp', featureNumber: 4),
    LearningActivity(title: '문장 구조', time: '5분', xp: '10xp', featureNumber: 5),
    LearningActivity(title: '에세이 작성', time: '15분', xp: '80xp', featureNumber: 6),
    LearningActivity(title: '형식 변환하기', time: '30분', xp: '150xp', featureNumber: 7),
    LearningActivity(title: '주제 추출', time: '5분', xp: '10xp', featureNumber: 8),
    LearningActivity(title: '자유 소감', time: '5분', xp: '10xp', featureNumber: 9),
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

  // /// Firestore 데이터를 다시 불러오는 함수
  // Future<void> _refreshData() async {
  //   final userId = ref.read(userIdProvider);
  //   final stageId = ref.read(selectedStageIdProvider);
  //
  //   if (userId != null && stageId != null) {
  //     final newStageData = await _loadStageData(userId, stageId);
  //     setState(() {
  //       _stageDataFuture = Future.value(newStageData); // 🚀 새로운 데이터로 화면 갱신
  //     });
  //   }
  // }

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

  Future<void> _onSubmit(StageData stage, CustomColors customColors) async {
    // 실제 유저 ID 가져오기
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    print(">> _onSubmit 시작: stageId=${stage.stageId}");

    // 현재 스테이지의 afterReading 활동 완료 처리
    await completeActivityForStage(
      userId: userId,
      stageId: stage.stageId,
      activityType: 'afterReading',
    );
    print(">> completeActivityForStage 호출 완료 for activityType 'afterReading'");

    // // 🔹 Firestore에서 현재 유저의 totalXP 가져오기
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    // final userSnapshot = await userRef.get();
    //
    // int currentTotalXP = 0; // 기본값 설정
    // if (userSnapshot.exists && userSnapshot.data()!.containsKey('totalXP')) {
    //   currentTotalXP = userSnapshot.data()!['totalXP'];
    // }

    // ✅ Provider를 통해 Firestore에서 XP 값을 가져옴
    final currentTotalXP = ref.read(userXPProvider).value ?? 0;


    // 🔹 현재 스테이지에서 완료된 XP 계산 (🔥 새로운 로직 추가)
    int earnedXP = 0;
    if (stage.arData?.featuresCompleted != null) {
      earnedXP = stage.arData!.featuresCompleted.entries
          .where((entry) => entry.value) // 완료된 미션만 필터링
          .map((entry) {
        // 해당 feature의 XP 값을 찾아 더함
        final featureNumber = int.parse(entry.key);
        return activities.firstWhere((a) => a.featureNumber == featureNumber).xp;
      })
          .map((xp) => int.parse(xp.replaceAll('xp', '')))
          .fold(0, (prev, e) => prev + e);
    }

    // 🔹 totalXP 업데이트 (기존 XP + 새로운 XP)
    final newTotalXP = currentTotalXP + earnedXP;
    print(">> totalXP 업데이트: $currentTotalXP + $earnedXP = $newTotalXP");

    await userRef.update({'totalXP': newTotalXP});
    print(">> Firestore totalXP 업데이트 완료!");

    // 업데이트가 완료된 후, Firestore에서 다시 현재 스테이지 데이터를 가져옵니다.
    final currentStageRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(stage.stageId);
    final updatedSnapshot = await currentStageRef.get();

    if (!updatedSnapshot.exists) {
      print("⚠️ 현재 스테이지(${stage.stageId}) 문서를 찾을 수 없습니다.");
      return;
    }

    final updatedStage =
    StageData.fromJson(updatedSnapshot.id, updatedSnapshot.data()!);
    print(">> 현재 스테이지 업데이트 확인: stageId=${updatedStage.stageId}, status=${updatedStage.status}, achievement=${updatedStage.achievement}");

    // 현재 스테이지가 완전히 완료되었는지 확인 (Status가 completed인 경우)
    if (updatedStage.status == StageStatus.completed) {
      final nextStageId = _getNextStageId(stage.stageId);
      if (nextStageId != null) {
        print(">> 다음 스테이지 ID: $nextStageId");
        final nextStageRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc(nextStageId);
        final nextSnapshot = await nextStageRef.get();

        if (nextSnapshot.exists) {
          final nextStage =
          StageData.fromJson(nextSnapshot.id, nextSnapshot.data()!);
          print(">> 다음 스테이지 현재 상태: stageId=${nextStage.stageId}, status=${nextStage.status}");
          if (nextStage.status == StageStatus.locked) {
            nextStage.status = StageStatus.inProgress;
            await nextStageRef.update(nextStage.toJson());
            print(">> 다음 스테이지 해금 완료: stageId=${nextStage.stageId} -> status=${nextStage.status}");
          } else {
            print(">> 다음 스테이지는 이미 해금되었거나 완료됨: stageId=${nextStage.stageId}, status=${nextStage.status}");
          }
        } else {
          print("⚠️ 다음 스테이지 문서($nextStageId)가 존재하지 않습니다.");
        }
      } else {
        print("⚠️ 다음 스테이지 ID를 계산할 수 없습니다. (현재 stageId: ${stage.stageId})");
      }
      // 현재 스테이지가 마지막 스테이지인지 확인 (각 섹션 4개 스테이지 기준)
      final currentStageNumber = int.tryParse(stage.stageId.split('_')[1]);
      if (currentStageNumber != null && currentStageNumber % 4 == 0) {
        String newCourse;
        if (currentStageNumber == 4) {
          newCourse = '코스2';
        } else if (currentStageNumber == 8) {
          newCourse = '코스3';
        } else if (currentStageNumber >= 12) {
          newCourse = '최종 완료';
        } else {
          newCourse = '코스1'; // 기본값, 필요시 조정
        }
        await updateUserCourse(userId, newCourse);
        print(">> 사용자 currentCourse 업데이트: $newCourse");
      }
    } else {
      print(">> 현재 스테이지가 아직 완료되지 않았습니다. (status: ${updatedStage.status})");
    }

    ref.invalidate(sectionProvider);

    // 결과 다이얼로그 띄우기
    showResultSaveDialog(
      context,
      customColors,
      "결과를 확인하시겠습니까?",
      "아니오",
      "예",
          (ctx) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(builder: (ctx) => ResultReportPage(earnedXP: earnedXP,)),
        );
      },
    );
  }

  /// 현재 스테이지 ID("stage_001")에서 다음 스테이지 ID("stage_002")를 구하는 헬퍼 함수
  String? _getNextStageId(String currentStageId) {
    final parts = currentStageId.split('_');
    if (parts.length != 2) return null;
    final number = int.tryParse(parts[1]);
    if (number == null) return null;
    final nextNumber = number + 1;
    final nextId = 'stage_${nextNumber.toString().padLeft(3, '0')}';
    print(">> _getNextStageId: $currentStageId -> $nextId");
    return nextId;
  }

  // 학습 결과 확인 버튼 (ResultButton) 위젯 수정: stageData를 추가로 전달
  Widget ResultButton(
      BuildContext context,
      int completedCount,
      CustomColors customColors,
      List<LearningActivity> availableActivities,
      StageData stageData,
      ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: completedCount / availableActivities.length < 1.0
          ? ButtonPrimary20(
        function: () {
          print("결과 확인하기 (미완료)");
        },
        title: '결과 확인하기',
      )
          : ButtonPrimary(
        function: () async {
          print("결과 확인하기");
          await _onSubmit(stageData, customColors);
        },
        title: '결과 확인하기',
      ),
    );
  }

  // 설명 팝업 표시 함수
  void _showExplanationPopup() {
    final customColors = ref.read(customColorsProvider);
    showDialog(
      barrierDismissible: false, // 다이얼로그 외부 클릭 방지
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

        // ✅ [1] DB에서 가져온 featureCompleted / features를 반영한 리스트로 만듦
        final availableActivities = <LearningActivity>[];

        for (final baseActivity in activities) {
          if (stageData.arData?.features.contains(baseActivity.featureNumber) ?? false) {
            final completed =
                stageData.arData?.featuresCompleted[baseActivity.featureNumber.toString()] ?? false;

            availableActivities.add(
              LearningActivity(
                title: baseActivity.title,
                time: baseActivity.time,
                xp: baseActivity.xp,
                featureNumber: baseActivity.featureNumber,
                isCompleted: completed,
              ),
            );
          }
        }

        // ✅ [2] 완료된 개수
        final completedCount =
            availableActivities.where((activity) => activity.isCompleted).length;

        // ✅ [3] XP 계산
        final totalXP = availableActivities
            .where((a) => a.isCompleted)
            .map((a) => int.parse(a.xp.replaceAll('xp', '')))
            .fold(0, (prev, e) => prev + e);

        final totalPossibleXP = availableActivities
            .map((a) => int.parse(a.xp.replaceAll('xp', '')))
            .fold(0, (prev, e) => prev + e);

        return Scaffold(
          backgroundColor: customColors.neutral90,
          appBar: CustomAppBar_2depth_6(
            title: '미션 선택',
            automaticallyImplyLeading: false,
            onIconPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
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
                        // ✅ [4] 진행도 출력 (같은 availableActivities 사용)
                        LearningProgress(
                          completedCount,
                          totalXP,
                          totalPossibleXP,
                          customColors,
                          context,
                          availableActivities,
                        ),
                        const SizedBox(height: 20),
                        ActivityList(context, customColors, stageData, availableActivities,),
                      ],
                    ),
                  ),
                ),
              ),
              ResultButton(context, completedCount, customColors,
                  availableActivities, stageData),
            ],
          ),
        );
      },
    );
  }

  Widget LearningProgress(
      int completedCount,
      int totalXP,
      int totalPossibleXP,
      CustomColors customColors,
      BuildContext context,
      List<LearningActivity> availableActivities,
      ) {
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
            percent: availableActivities.isEmpty
                ? 0
                : completedCount / availableActivities.length,
            center: Text(
              '${(availableActivities.isEmpty ? 0 : (completedCount / availableActivities.length * 100)).toStringAsFixed(0)}%',
              style: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
            ),
            progressColor: customColors.primary,
            backgroundColor: customColors.neutral80 ?? Colors.grey,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$totalXP/$totalPossibleXP xp',
                  style: heading_medium(context).copyWith(color: customColors.neutral30)),
              const SizedBox(height: 8),
              Text('$completedCount 미션 완료',
                  style: body_xsmall(context).copyWith(color: customColors.neutral60)),
            ],
          ),
        ],
      ),
    );
  }

  // 학습 활동 목록
  Widget ActivityList(BuildContext context, CustomColors customColors, StageData stageData, List<LearningActivity> availableActivities) {
    // 완료되지 않은 미션이 위쪽에 오도록 정렬
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
          ...sortedActivities.map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: ShapeDecoration(
                color: activity.isCompleted ? customColors.neutral90 : customColors.neutral100,
                shape: RoundedRectangleBorder(
                  side: activity.isCompleted
                      ? BorderSide.none
                      : BorderSide(width: 1, color: customColors.neutral80 ?? const Color(0xFFCDCED3)),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActivityText(activity, customColors),
                  // _buildActivityButton 호출 시 StageData 전달
                  _buildActivityButton(context, activity, customColors, stageData),
                ],
              ),
            ),
          )),
        ],
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
  Widget _buildActivityButton(BuildContext context, LearningActivity activity, CustomColors customColors, StageData stageData) {
    return ElevatedButton(
      onPressed: activity.isCompleted
          ? null
          : () async {
        // // Firestore 업데이트: 해당 feature의 완료 상태를 true로 변경
        // await _updateFeatureCompletion(stageData, activity.featureNumber, true);
        // setState(() {
        //   activity.isCompleted = true;
        // });
        // 각 미션에 해당하는 페이지로 이동
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
        style: body_xsmall_semi(context).copyWith(
            color: activity.isCompleted ? customColors.neutral30 : customColors.neutral100),
      ),
    );
  }

  // 학습 활동에 맞는 페이지 반환
  Widget _getActivityPage(String title) {
    switch (title) {
      case '결말 바꾸기':
        // return ChangeEndingMain();
      case '요약':
        return CSLearning();
      case '토론':
        return DebatePage();
      case '다이어그램':
        return RootedTreeScreen();
      case '문장 구조':
        return WritingFormMain();
      case '에세이 작성':
        // return WritingEssayMain();
      case '형식 변환하기':
        // return FormatConversionMain();
      case '주제 추출':
        return ParagraphAnalysisMain();
      case '자유 소감':
        return ReviewWritingMain();
      default:
        return const SizedBox();
    }
  }
}

/// 지정된 feature의 완료 상태를 업데이트하는 함수
Future<void> updateFeatureCompletion(StageData stage, int featureNumber, bool isCompleted) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || stage.arData == null) return;

  // StageData 내에서 AR feature 완료 상태 업데이트
  stage.updateArFeatureCompletion(featureNumber, isCompleted);

  // Firestore에 반영 (전체 arData를 업데이트)
  final stageRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('progress')
      .doc(stage.stageId);

  await stageRef.update({
    'arData': stage.arData!.toJson(),
  });
}


