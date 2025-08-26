/// File: choose_activities.dart
/// Purpose: 읽기 후 학습 선택 화면 (progress 문서의 arData에 따라 표시/계산)
/// Author: 강희 (수정됨)
/// Last Modified: 2025-08-23 (L10N 적용, 라우팅 안정화: title → featureNumber)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // L10N: 추가

import '../../../model/stage_data.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/custom_colors_provider.dart' as custom_colors_provider;
import '../../../viewmodel/section_provider.dart';
import '../../../viewmodel/user_service.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import '../../components/custom_button.dart';
import '../../home/stage_provider.dart';
import '../Result_Report.dart';
import '../../../services/firestore_paths.dart'; // 파일 상단 import 추가

// Activities
import 'GA_03_01_change_ending/CE_main.dart';
import 'GA_03_02_content_summary/CS_learning.dart';
import 'GA_03_03_debate_activity/DA_learning.dart';
import 'GA_03_04_diagram/diagram_learning.dart';
import 'GA_03_05_writing_form/writing_form_main.dart';
import 'GA_03_08_paragraph_analysis/paragraph_analysis_main.dart';
import 'GA_03_09_review_writing/review_writing_main.dart';

/// 학습 활동 데이터 모델
// 기존 LearningActivity 교체
class LearningActivity {
  final String titleKey; // 번역 키
  final int minutes;     // 시간(분)
  final int xp;          // XP 정수
  final int featureNumber;
  final bool isCompleted;

  const LearningActivity({
    required this.titleKey,
    required this.minutes,
    required this.xp,
    required this.featureNumber,
    this.isCompleted = false,
  });

  LearningActivity copyWith({bool? isCompleted}) => LearningActivity(
    titleKey: titleKey,
    minutes: minutes,
    xp: xp,
    featureNumber: featureNumber,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class LearningActivitiesPage extends ConsumerStatefulWidget {
  @override
  _LearningActivitiesPageState createState() => _LearningActivitiesPageState();
}

class _LearningActivitiesPageState extends ConsumerState<LearningActivitiesPage> {

  // static const List<LearningActivity> baseActivities = [
  //
  //   LearningActivity(titleKey: 'activity_change_ending', timeKey: 'time_minutes', xp: '100xp', featureNumber: 1),
  //
  //   LearningActivity(titleKey: 'activity_summary', timeKey: 'time_minutes', xp: '50xp', featureNumber: 2),
  //
  //   LearningActivity(titleKey: 'debate_title', timeKey: 'time_minutes', xp: '120xp', featureNumber: 3),
  //
  //   LearningActivity(titleKey: 'diagram_title', timeKey: 'time_minutes', xp: '10xp', featureNumber: 4),
  //
  //   LearningActivity(titleKey: 'activity_sentence_structure', timeKey: 'time_minutes', xp: '10xp', featureNumber: 5),
  //
  //   LearningActivity(titleKey: 'activity_essay_writing', timeKey: 'time_minutes', xp: '80xp', featureNumber: 6),
  //
  //   LearningActivity(titleKey: 'activity_format_conversion', timeKey: 'time_minutes', xp: '150xp', featureNumber: 7),
  //
  //   LearningActivity(titleKey: 'activity_topic_extraction', timeKey: 'time_minutes', xp: '10xp', featureNumber: 8),
  //
  //   LearningActivity(titleKey: 'activity_free_opinion', timeKey: 'time_minutes', xp: '10xp', featureNumber: 9),
  // ];

  // 베이스 활동 목록(정적) - L10N: title/time을 키로 저장
  static const List<LearningActivity> baseActivities = [
    // feature 1: 결말 바꾸기 (키 필요: activity_change_ending)
    LearningActivity(titleKey: 'activity_change_ending',      minutes: 20, xp: 100, featureNumber: 1),
    // feature 2: 요약 (기존 키 활용: activity_summary 또는 summary_mission_title/summary)
    LearningActivity(titleKey: 'activity_summary',            minutes: 10, xp:  50, featureNumber: 2),
    // feature 3: 토론
    LearningActivity(titleKey: 'debate_title',                minutes: 25, xp: 120, featureNumber: 3),
    // feature 4: 다이어그램
    LearningActivity(titleKey: 'diagram_title',               minutes:  5, xp:  10, featureNumber: 4),
    // feature 5: 문장 구조 (키 필요: activity_sentence_structure)
    LearningActivity(titleKey: 'activity_sentence_structure', minutes:  5, xp:  10, featureNumber: 5),
    // feature 6: 에세이 작성 (키 필요: activity_essay_writing)
    LearningActivity(titleKey: 'activity_essay_writing',      minutes: 15, xp:  80, featureNumber: 6),
    // feature 7: 형식 변환하기 (키 필요: activity_format_conversion)
    LearningActivity(titleKey: 'activity_format_conversion',  minutes: 30, xp: 150, featureNumber: 7),
    // feature 8: 주제 추출 (키 필요: activity_topic_extraction)
    LearningActivity(titleKey: 'activity_topic_extraction',   minutes:  5, xp:  10, featureNumber: 8),
    // feature 9: 자유 소감 (키 필요: activity_free_opinion)
    LearningActivity(titleKey: 'activity_free_opinion',       minutes:  5, xp:  10, featureNumber: 9),
  ];

  @override
  void initState() {
    super.initState();
    // 설명 팝업
    Future.microtask(_showExplanationPopup);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context); // 팝업 닫기
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(custom_colors_provider.customColorsProvider);
    final uid = ref.watch(userIdProvider);
    final stageId = ref.watch(selectedStageIdProvider);

    // 현재 선택된 스테이지의 정적 마스터/조립 데이터 (제목 등 표시용)
    final stage = ref.watch(currentStageProvider);

    if (uid == null || stageId == null) {
      return Scaffold(
        backgroundColor: customColors.neutral90,
        body: Center(child: Text('info_not_available'.tr(), style: body_small(context))), // L10N
      );
    }
    if (stage == null) {
      return Scaffold(
        backgroundColor: customColors.neutral90,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 진행(progress) 문서 스트림: features / featuresCompleted 는 여기서 읽음
    final progressDocStream = FirebaseFirestore.instance
        .doc('${FsPaths.userProgressSections(uid)}/$stageId') // users/{uid}/progress/root/sections/{stageId}
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: progressDocStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            backgroundColor: customColors.neutral90,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() ?? const <String, dynamic>{};
        final arRaw = (data['arData'] is Map) ? data['arData'] as Map : const <String, dynamic>{};
        final features = _extractFeatureIds(arRaw['features'], fallback: stage.arData?.features);
        final fcRaw = _extractFeaturesCompleted(arRaw['featuresCompleted'],
            fallback: stage.arData?.featuresCompleted);
        final Set<int> allowedSet = features.toSet();

        final availableActivities = baseActivities
            .where((a) => allowedSet.contains(a.featureNumber))
            .map((a) => a.copyWith(isCompleted: (fcRaw['${a.featureNumber}'] == true)))
            .toList();

        // 진행/XP 계산 교체
        final completedCount = availableActivities.where((a) => a.isCompleted).length;
        final totalXP = availableActivities
            .where((a) => a.isCompleted)
            .fold<int>(0, (sum, a) => sum + a.xp);
        final totalPossibleXP = availableActivities
            .fold<int>(0, (sum, a) => sum + a.xp);


        return Scaffold(
          backgroundColor: customColors.neutral90,
          appBar: CustomAppBar_2depth_6(
            title: 'missions_title'.tr(), // L10N: 미션 선택 → 미션(상단 타이틀 키 재사용)
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
                        _learningProgress(
                          completedCount,
                          totalXP,
                          totalPossibleXP,
                          customColors,
                          context,
                          availableActivities,
                        ),
                        const SizedBox(height: 20),
                        _activityList(context, customColors, stageId, availableActivities),
                      ],
                    ),
                  ),
                ),
              ),
              _resultButton(
                context: context,
                completedCount: completedCount,
                customColors: customColors,
                availableActivities: availableActivities,
                stageId: stageId,
                earnedXP: totalXP, // 이미 계산한 값 재사용
              ),
            ],
          ),
        );
      },
    );
  }

  // 진행 위젯
  Widget _learningProgress(
      int completedCount,
      int totalXP,
      int totalPossibleXP,
      CustomColors customColors,
      BuildContext context,
      List<LearningActivity> availableActivities,
      ) {
    final percent = availableActivities.isEmpty ? 0.0 : completedCount / availableActivities.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 10.0,
            animation: true,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              '${(percent * 100).toStringAsFixed(0)}%',
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
              // L10N: xp 진행 텍스트(키가 없다면 그대로 숫자 + "xp")
              Text('$totalXP/$totalPossibleXP XP',
                style: heading_medium(context).copyWith(color: customColors.neutral30),
              ),
              const SizedBox(height: 8),
              // L10N: "{n} 미션 완료" → en의 경우 "{n} missions completed"
              Text('missions_completed'.tr(args: ['${completedCount}']),
                style: body_xsmall(context).copyWith(color: customColors.neutral60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 활동 리스트
  Widget _activityList(
      BuildContext context,
      CustomColors customColors,
      String stageId,
      List<LearningActivity> availableActivities,
      ) {
    final sorted = List<LearningActivity>.from(availableActivities)
      ..sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1; // 미완료 먼저, 완료 뒤
      });


    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('missions_title'.tr(), style: body_small_semi(context)), // L10N
          const SizedBox(height: 20),
          ...sorted.map((activity) => Padding(
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
                  _buildActivityText(context, activity, customColors),
                  _buildActivityButton(context, activity, customColors, stageId),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityText(BuildContext context, LearningActivity activity, CustomColors customColors) {
    final title = activity.titleKey.tr(); // 각 미션의 로컬라이즈된 이름

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        const SizedBox(height: 8),
        if (!activity.isCompleted)
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: customColors.neutral30),
              const SizedBox(width: 4),
              Text('time_minutes'.tr(args: ['${activity.minutes}']),
                  style: body_xsmall(context).copyWith(color: customColors.neutral30)),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: customColors.neutral30),
              const SizedBox(width: 4),
              Text('${activity.xp} XP',
                  style: body_xsmall(context).copyWith(color: customColors.neutral30)),
            ],
          )
        else
          Text('earned_xp_message'.tr(args: ['${activity.xp}']),
              style: body_xsmall(context).copyWith(color: customColors.primary)),
      ],
    );
  }


  Widget _buildActivityButton(
      BuildContext context,
      LearningActivity activity,
      CustomColors customColors,
      String stageId,
      ) {
    return ElevatedButton(
      onPressed: activity.isCompleted
          ? null
          : () async {
        // 각 미션 페이지로 이동 (L10N 안전: featureNumber로 분기)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _getActivityPageByFeature(activity.featureNumber)),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        backgroundColor: activity.isCompleted ? customColors.neutral80 : customColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        activity.isCompleted ? 'done'.tr() : 'start_button'.tr(), // L10N
        style: body_xsmall_semi(context)
            .copyWith(color: activity.isCompleted ? customColors.neutral30 : customColors.neutral100),
      ),
    );
  }

  // 학습 활동에 맞는 페이지 반환 (L10N 안전: featureNumber 기반)
  Widget _getActivityPageByFeature(int featureNumber) {
    switch (featureNumber) {
      case 1:
        return const SizedBox(); // ChangeEndingMain(); // 아직 미연결이면 비워둠
      case 2:
        return CSLearning();
      case 3:
        return DebatePage();
      case 4:
        return RootedTreeScreen();
      case 5:
        return WritingFormMain();
      case 6:
        return const SizedBox(); // WritingEssayMain();
      case 7:
        return const SizedBox(); // FormatConversionMain();
      case 8:
        return ParagraphAnalysisMain();
      case 9:
        return ReviewWritingMain();
      default:
        return const SizedBox();
    }
  }

  // 제출 버튼
  Widget _resultButton({
    required BuildContext context,
    required int completedCount,
    required CustomColors customColors,
    required List<LearningActivity> availableActivities,
    required String stageId,
    required int earnedXP,
  }) {
    final allDone = availableActivities.isNotEmpty && completedCount == availableActivities.length;
    final title = 'result_check'.tr(); // "결과 확인하기" / "View results"
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: allDone
          ? ButtonPrimary(
        function: () async {
          await _onSubmit(stageId, earnedXP, customColors);
        },
        title: title, // L10N: "결과 확인하기"에 해당하는 키가 없다면 result_title로 대체
      )
          : ButtonPrimary20(
        function: () {
          debugPrint("result button pressed (incomplete)");
        },
        title: title,
      ),
    );
  }

  // 결과 팝업
  void _showExplanationPopup() {
    final customColors = ref.read(custom_colors_provider.customColorsProvider);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 28),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    // L10N: 안내 문구 → 기존 키 재사용
                    'reading_greeting'.tr(),
                    textAlign: TextAlign.center,
                    style: body_large_semi(context).copyWith(color: customColors.neutral30),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 172,
                  height: 172,
                  child: Image.asset("assets/images/book_star.png"),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    // L10N: 팁 문구 → selection_tip 재사용
                    'selection_tip'.tr(),
                    textAlign: TextAlign.center,
                    style: body_small(context).copyWith(color: customColors.neutral60),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 제출: afterReading 완료 + XP 반영 + 다음 스테이지 해금(조건부)
  Future<void> _onSubmit(String stageId, int earnedXP, CustomColors customColors) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    final stageRef = FirebaseFirestore.instance.doc('${FsPaths.userProgressSections(userId)}/$stageId');

    // 1) progress 섹션 문서에 activityCompleted.afterReading = true, status='completed'
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(stageRef);
        if (!snap.exists) return;

        final data = Map<String, dynamic>.from(snap.data()!);
        final activityCompleted = Map<String, dynamic>.from(data['activityCompleted'] ?? const {});

        activityCompleted['afterReading'] = true;

        tx.update(stageRef, {
          'activityCompleted': activityCompleted,
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e, st) {
      debugPrint('mark afterReading completed failed: $e');
      debugPrint('$st');
    }

    // 2) XP 누적
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final currentTotalXP = ref.read(userXPProvider).value ?? 0;
    final newTotalXP = currentTotalXP + earnedXP;
    await userRef.update({'totalXP': newTotalXP});

    // 3) 다음 스테이지 해금 (지금 막 status를 completed로 바꿨으니 조건 만족)
    await _maybeUnlockNextStage(userId, stageId);

    // 4) 섹션/홈 리프레시
    ref.invalidate(sectionProvider);

    // 5) 결과 다이얼로그 → 리포트
    showResultSaveDialog(
      context,
      customColors,
      'save_and_exit_prompt'.tr(), // L10N: "Do you want to save the result and exit?"
      'no'.tr(),
      'yes'.tr(),
          (ctx) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(builder: (ctx) => ResultReportPage(earnedXP: earnedXP)),
        );
      },
    );
  }

  Future<void> _maybeUnlockNextStage(String userId, String currentStageId) async {
    final nextId = _getNextStageId(currentStageId);
    if (nextId == null) return;

    final currentRef = FirebaseFirestore.instance.doc('${FsPaths.userProgressSections(userId)}/$currentStageId');
    final nextRef = FirebaseFirestore.instance.doc('${FsPaths.userProgressSections(userId)}/$nextId');

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final currentSnap = await tx.get(currentRef);
      if (!currentSnap.exists) return;

      final statusStr = (currentSnap.data()?['status'] ?? 'locked').toString();
      if (statusStr != 'completed') return; // 아직 완료 아님

      final nextSnap = await tx.get(nextRef);
      if (!nextSnap.exists) return;

      final nextStatusStr = (nextSnap.data()?['status'] ?? 'locked').toString();
      if (nextStatusStr == 'locked') {
        tx.update(nextRef, {'status': 'inProgress'});
      }
    });
  }

  String? _getNextStageId(String currentStageId) {
    final parts = currentStageId.split('_');
    if (parts.length != 2) return null;
    final number = int.tryParse(parts[1]);
    if (number == null) return null;
    final nextNumber = number + 1;
    return 'stage_${nextNumber.toString().padLeft(3, '0')}';
  }
}

/// --------- 미션 완료 처리 (featuresCompleted) 트랜잭션 버전 ---------
Future<void> updateFeatureCompletion({
  required String stageId,
  required int featureNumber,
  required bool isCompleted,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    debugPrint("updateFeatureCompletion: userId is null");
    return;
  }

  final stageRef = FirebaseFirestore.instance.doc('${FsPaths.userProgressSections(userId)}/$stageId');

  try {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(stageRef);
      if (!snap.exists) return;

      final data = Map<String, dynamic>.from(snap.data()!);
      final ar = Map<String, dynamic>.from((data['arData'] ?? const {}));
      final fc = Map<String, dynamic>.from((ar['featuresCompleted'] ?? const {}));

      fc['$featureNumber'] = isCompleted;
      ar['featuresCompleted'] = fc;
      tx.update(stageRef, {'arData': ar});
    });

    // 사용자 지표 업데이트(원자 증가)
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({'completedMissionCount': FieldValue.increment(1)});
  } catch (e, stack) {
    debugPrint("updateFeatureCompletion error: $e");
    debugPrint("$stack");
  }
}

List<int> _extractFeatureIds(dynamic raw, {dynamic fallback}) {
  List<int>? parse(dynamic v) {
    if (v is List) {
      final out = <int>[];
      for (final e in v) {
        if (e is int) out.add(e);
        else {
          final n = int.tryParse(e.toString());
          if (n != null) out.add(n);
        }
      }
      return out;
    }
    if (v is Map) {
      final out = <int>[];
      for (final val in v.values) {
        final p = parse(val);
        if (p != null) out.addAll(p);
      }
      return out.isEmpty ? null : out;
    }
    try {
      final json = (v as dynamic).toJson();
      if (json is Map) return parse(json);
    } catch (_) {}
    return null;
  }

  return parse(raw) ?? parse(fallback) ?? const <int>[];
}

Map<String, bool> _extractFeaturesCompleted(dynamic raw, {dynamic fallback}) {
  Map<String, bool>? parse(dynamic v) {
    if (v is Map) {
      final out = <String, bool>{};
      v.forEach((k, val) {
        if (val is bool) out['$k'] = val;
        else if (val is num) out['$k'] = val != 0;
        else if (val is String) {
          final t = val.toLowerCase();
          if (t == 'true' || t == '1') out['$k'] = true;
          if (t == 'false' || t == '0') out['$k'] = false;
        }
      });
      return out;
    }
    try {
      final json = (v as dynamic).toJson();
      if (json is Map) return parse(json);
    } catch (_) {}
    return null;
  }
  return parse(raw) ?? parse(fallback) ?? const <String, bool>{};
}
