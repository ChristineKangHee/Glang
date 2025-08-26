// lib/view/feature/reading/GA_02/RD_main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

// 모델
import 'package:readventure/model/stage_data.dart';
import 'package:readventure/model/reading_data.dart';

// UI
import 'package:readventure/view/feature/reading/result_dialog.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_mcq/mcq_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_ox/ox_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02/toolbar_component.dart';
import 'package:readventure/view/home/stage_provider.dart';
import 'package:readventure/view/feature/after_read/choose_activities.dart';

// 로케일 헬퍼
import 'package:readventure/util/locale_text.dart';

// 테마/공용
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import '../../../components/alarm_dialog.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../quiz_data.dart';
import 'package:readventure/services/progress_repository.dart';


class RdMain extends ConsumerStatefulWidget {
  const RdMain({super.key});

  @override
  _RdMainState createState() => _RdMainState();
}

class _RdMainState extends ConsumerState<RdMain> with SingleTickerProviderStateMixin {
  bool _showOxQuiz = false;
  bool _showMcqQuiz = false;

  // 단일 퀴즈 기준
  List<int> mcqUserAnswers = [];
  List<bool> oxUserAnswers = [];

  bool mcqCompleted = false;
  bool oxCompleted = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 객관식(MCQ) 정답 체크 (리스트 스키마 대응: 첫 문제만)
  void checkMcqAnswer(int selectedIndex, StageData currentStage) {
    final rd = currentStage.readingData;
    if (rd == null || rd.multipleChoice.isEmpty) return;
    final mcqQuiz = rd.multipleChoice.first;

    final bool isCorrect = selectedIndex == mcqQuiz.correctIndex;

    setState(() {
      mcqUserAnswers = [selectedIndex];
      mcqCompleted = true;
    });

    ResultDialog.show(
      context,
      isCorrect,
      lx(context, mcqQuiz.explanation),
          () {
        if (!mounted) return;
        setState(() {
          _showMcqQuiz = false;
          _animationController.reverse();
        });
      },
    );
  }

  // OX 정답 체크 (리스트 스키마 대응: 첫 문제만)
  void checkOxAnswer(bool selectedAnswer, StageData currentStage) {
    final rd = currentStage.readingData;
    if (rd == null || rd.oxQuiz.isEmpty) return;
    final oxQuiz = rd.oxQuiz.first;

    final bool isCorrect = selectedAnswer == oxQuiz.correctAnswer;

    setState(() {
      oxUserAnswers = [selectedAnswer];
      oxCompleted = true;
    });

    ResultDialog.show(
      context,
      isCorrect,
      lx(context, oxQuiz.explanation),
          () {
        if (!mounted) return;
        setState(() {
          _showOxQuiz = false;
          _animationController.reverse();
        });
      },
    );
  }

  // 퀴즈 표시 토글 (존재하지 않으면 무시)
  void toggleQuizVisibility(String quizType, StageData currentStage) {
    final rd = currentStage.readingData;
    final hasMcq = rd != null && rd.multipleChoice.isNotEmpty;
    final hasOx  = rd != null && rd.oxQuiz.isNotEmpty;

    setState(() {
      if (quizType == 'MCQ') {
        if (!hasMcq) return;
        _showMcqQuiz = !_showMcqQuiz;
        _showOxQuiz = false;
      } else {
        if (!hasOx) return;
        _showOxQuiz = !_showOxQuiz;
        _showMcqQuiz = false;
      }
      if (_showOxQuiz || _showMcqQuiz) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // 진행도 저장 (duringReading -> true)
// 진행도 저장 (duringReading -> true)
  Future<void> _onSubmit(StageData stage) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    try {
      await ProgressRepository.instance.setStageProgress(
        uid: uid,
        stageId: stage.stageId,
        data: {
          // duringReading 완료 처리
          'activityCompleted': {
            'duringReading': true,
          },

          // 필요하면 상태/진행도도 함께 병합 (주석 해제해서 사용)
          // 'status': 'inProgress',
          // 'achievement': 66, // 예시: 읽기 단계 완료 시 66%로
        },
      );
    } catch (e, st) {
      debugPrint('❌ duringReading 업데이트 실패: $e\n$st');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LearningActivitiesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final currentStage = ref.watch(currentStageProvider);

    if (currentStage == null) {
      return Scaffold(
        appBar: CustomAppBar_2depth_8(title: "loading".tr()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final rd = currentStage.readingData;
    if (rd == null) {
      return Scaffold(
        appBar: CustomAppBar_2depth_8(title: "loading".tr()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 본문 세그먼트 (LocalizedList → List<String>)
    final List<String> segs = llx(context, rd.textSegments);

    // 퀴즈 존재 여부/첫 문제
    final hasMcq = rd.multipleChoice.isNotEmpty;
    final hasOx  = rd.oxQuiz.isNotEmpty;
    final mcq = hasMcq ? rd.multipleChoice.first : null;
    final ox  = hasOx  ? rd.oxQuiz.first : null;

    // 모든 퀴즈를 요구하되, 없는 퀴즈는 자동 완료 취급
    final canSubmit = (hasMcq ? mcqCompleted : true) && (hasOx ? oxCompleted : true);

    return Scaffold(
      appBar: CustomAppBar_2depth_8(
        // StageData.subdetailTitle는 LocalizedText → String 변환
        title: lx(context, currentStage.subdetailTitle),
        onClosePressed: () {
          showResultSaveDialog(
            context,
            customColors,
            "save_and_exit_prompt".tr(),
            "no".tr(),
            "yes".tr(),
                (ctx) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 본문 1
            SelectableText(
              (segs.isNotEmpty) ? segs[0] : '',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(
                customColors: customColors,
                readingData: rd,
                stageId: currentStage.stageId,
                subdetailTitle: lx(context, currentStage.subdetailTitle),
              ),
            ),

            const SizedBox(height: 16),

            // 📌 사지선다(MCQ)
            if (hasMcq)
              GestureDetector(
                onTap: () => toggleQuizVisibility('MCQ', currentStage),
                child: Column(
                  children: [
                    _buildQuizButton(customColors, 'MCQ', mcqCompleted),
                    SizeTransition(
                      sizeFactor: _animation,
                      child: _showMcqQuiz
                          ? McqQuiz(
                        question: McqQuestion(
                          paragraph: lx(context, mcq!.question),
                          options: llx(context, mcq.choices),
                          correctAnswerIndex: mcq.correctIndex,
                          explanation: lx(context, mcq.explanation),
                        ),
                        onAnswerSelected: (index) => checkMcqAnswer(index, currentStage),
                        userAnswer: mcqUserAnswers.isNotEmpty ? mcqUserAnswers[0] : null,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // 📌 본문 2
            if (segs.length > 1)
              SelectableText(
                segs[1],
                style: reading_textstyle(context).copyWith(color: customColors.neutral0),
                selectionControls: Read_Toolbar(
                  customColors: customColors,
                  readingData: rd,
                  stageId: currentStage.stageId,
                  subdetailTitle: lx(context, currentStage.subdetailTitle),
                ),
              ),

            const SizedBox(height: 16),

            // 📌 OX
            if (hasOx)
              GestureDetector(
                onTap: () => toggleQuizVisibility('OX', currentStage),
                child: Column(
                  children: [
                    _buildQuizButton(customColors, 'OX', oxCompleted),
                    SizeTransition(
                      sizeFactor: _animation,
                      child: _showOxQuiz
                          ? OxQuiz(
                        question: OxQuestion(
                          paragraph: lx(context, ox!.question),
                          correctAnswer: ox.correctAnswer,
                          explanation: lx(context, ox.explanation),
                        ),
                        onAnswerSelected: (answer) => checkOxAnswer(answer, currentStage),
                        userAnswer: oxUserAnswers.isNotEmpty ? oxUserAnswers[0] : null,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // 📌 본문 3
            if (segs.length > 2)
              SelectableText(
                segs[2],
                style: reading_textstyle(context).copyWith(color: customColors.neutral0),
                selectionControls: Read_Toolbar(
                  customColors: customColors,
                  readingData: rd,
                  stageId: currentStage.stageId,
                  subdetailTitle: lx(context, currentStage.subdetailTitle),
                ),
              ),

            const SizedBox(height: 40),

            // 📌 '읽기 완료' (존재하는 퀴즈만 완료되면 활성화)
            ButtonPrimary_noPadding(
              function: () => _onSubmit(currentStage),
              title: "reading_complete".tr(),
              condition: canSubmit ? "not null" : "null",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(CustomColors customColors, String quizType, bool isCompleted) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isCompleted ? customColors.primary20 : customColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'Q',
        style: body_small_semi(context).copyWith(color: customColors.secondary),
      ),
    );
  }
}
