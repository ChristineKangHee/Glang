import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// 새 모델 파일을 사용하도록 import 경로 수정
import 'package:readventure/model/stage_data.dart';
import 'package:readventure/view/feature/reading/result_dialog.dart';
import 'package:readventure/view/feature/reading/GA_02_02_subjective/subjective_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_mcq/mcq_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_ox/ox_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02/toolbar_component.dart';
import 'package:readventure/view/home/stage_provider.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import '../../../../model/reading_data.dart';
import '../../../../model/section_data.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../after_read/choose_activities.dart';
import '../quiz_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RdMain extends ConsumerStatefulWidget {
  const RdMain({super.key});

  @override
  _RdMainState createState() => _RdMainState();
}


class _RdMainState extends ConsumerState<RdMain> with SingleTickerProviderStateMixin {
  // late StageData currentStage; // 현재 선택된 스테이지 데이터

  bool _showOxQuiz = false;
  bool _showMcqQuiz = false;

  // 이전에는 여러 문제를 위한 리스트였으나, 새 모델은 단일 퀴즈만 있으므로 단일 값으로 처리
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
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 객관식(MCQ) 퀴즈 정답 체크
  void checkMcqAnswer(int selectedIndex, StageData currentStage) {
    final mcqQuiz = currentStage.readingData?.multipleChoice;
    if (mcqQuiz == null) return;

    // 인덱스를 'A', 'B', 'C', ... 로 변환 (예: 0 -> 'A')
    String selectedLetter = String.fromCharCode(65 + selectedIndex);
    bool isCorrect = selectedLetter == mcqQuiz.correctAnswer;

    setState(() {
      // 단일 문제이므로 리스트를 초기화하고 하나의 값만 추가합니다.
      mcqUserAnswers = [selectedIndex];
      mcqCompleted = true;
    });

    // 새 모델에는 설명 필드가 없으므로 빈 문자열 전달
    ResultDialog.show(context, isCorrect, mcqQuiz.explanation, () {
      setState(() {
        _showMcqQuiz = false;
        _animationController.reverse();
      });
    });
  }

  // OX 퀴즈 정답 체크
  void checkOxAnswer(bool selectedAnswer, StageData currentStage) {
    final oxQuiz = currentStage.readingData?.oxQuiz;
    if (oxQuiz == null) return;

    bool isCorrect = selectedAnswer == oxQuiz.correctAnswer;

    setState(() {
      oxUserAnswers = [selectedAnswer];
      oxCompleted = true;
    });

    // 새 모델에는 설명 필드가 없으므로 빈 문자열 전달
    ResultDialog.show(context, isCorrect, oxQuiz.explanation, () {
      setState(() {
        _showOxQuiz = false;
        _animationController.reverse();
      });
    });
  }

  // 퀴즈 표시 여부 토글
  void toggleQuizVisibility(String quizType) {
    setState(() {
      if (quizType == 'MCQ') {
        _showMcqQuiz = !_showMcqQuiz;
        _showOxQuiz = false;
      } else {
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

  // ✅ 진행도를 저장하는 함수 (duringReading -> true)
  Future<void> _onSubmit(StageData stage) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    await completeActivityForStage(
      userId: userId,
      stageId: stage.stageId,
      activityType: 'duringReading', // ✅ duringReading 값을 true로 변경
    );

    // ✅ 저장 완료 후 다음 페이지로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // settings: RouteSettings(name: 'LearningActivitiesPage'),
        builder: (context) => LearningActivitiesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final currentStage = ref.watch(currentStageProvider);

    if (currentStage == null) {
      return Scaffold(
        appBar: CustomAppBar_2depth_8(title: "로딩 중..."),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // 제목은 새 모델의 subdetailTitle 사용
      appBar: CustomAppBar_2depth_8(title: currentStage.subdetailTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 본문 1: 읽기 중(READING) 데이터의 textSegments[0] 사용
            SelectableText(
              currentStage.readingData?.textSegments[0] ?? '',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors, readingData: currentStage.readingData!,),
            ),
            const SizedBox(height: 16),

            // 📌 사지선다(MCQ) 퀴즈
            GestureDetector(
              onTap: () => toggleQuizVisibility('MCQ'),
              child: Column(
                children: [
                  _buildQuizButton(customColors, 'MCQ', mcqCompleted),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: _showMcqQuiz
                        ? McqQuiz(
                      // 새 모델의 객관식 퀴즈 데이터 사용
                      question: McqQuestion(
                        paragraph: currentStage.readingData!.multipleChoice.question,
                        options: currentStage.readingData!.multipleChoice.choices,
                        correctAnswerIndex: currentStage.readingData!.multipleChoice.correctAnswer.codeUnitAt(0) - 65,
                        explanation: currentStage.readingData!.multipleChoice.explanation,
                      ),
                      onAnswerSelected: (index) => checkMcqAnswer(index, currentStage),
                      // 단일 문제이므로 인덱스 0 사용
                      userAnswer: mcqUserAnswers.isNotEmpty ? mcqUserAnswers[0] : null,
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 본문 2: 읽기 중(READING) 데이터의 textSegments[1] 사용
            SelectableText(
              currentStage.readingData?.textSegments[1] ?? '',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors, readingData: currentStage.readingData!,),
            ),
            const SizedBox(height: 16),

            // 📌 OX 퀴즈
            GestureDetector(
              onTap: () => toggleQuizVisibility('OX'),
              child: Column(
                children: [
                  _buildQuizButton(customColors, 'OX', oxCompleted),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: _showOxQuiz
                        ? OxQuiz(
                      // 새 모델의 OX 퀴즈 데이터 사용
                      question: OxQuestion(
                        paragraph: currentStage.readingData!.oxQuiz.question,
                        correctAnswer: currentStage.readingData!.oxQuiz.correctAnswer,
                        explanation: currentStage.readingData!.oxQuiz.explanation,
                      ),
                      onAnswerSelected: (answer) => checkOxAnswer(answer, currentStage),
                      userAnswer: oxUserAnswers.isNotEmpty ? oxUserAnswers[0] : null,
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 본문 3: 읽기 중(READING) 데이터의 textSegments[2] 사용
            SelectableText(
              currentStage.readingData?.textSegments[2] ?? '',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors, readingData: currentStage.readingData!,),
            ),

            const SizedBox(height: 40),

            // 📌 '읽기 완료' 버튼: 이후 활동 선택 페이지로 이동
            ButtonPrimary_noPadding(
              function: () => _onSubmit(currentStage), // ✅ 진행도 저장 후 이동
              title: "읽기 완료",
              condition: mcqCompleted && oxCompleted ? "not null" : "null", // ✅ 모든 문제를 풀었을 때만 활성화
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

// Read_Toolbar 클래스 (수정 후)
class Read_Toolbar extends MaterialTextSelectionControls {
  final customColors;
  final ReadingData readingData; // 추가: ReadingData 필드

  Read_Toolbar({required this.customColors, required this.readingData});

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset position,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition,
      ) {
    const double toolbarHeight = 50;
    const double toolbarWidth = 135;

    final screenSize = MediaQuery.of(context).size;
    double leftPosition =
        (endpoints.first.point.dx + endpoints.last.point.dx) / 2 - toolbarWidth / 2 + 16;
    double topPosition =
        endpoints.first.point.dy + globalEditableRegion.top - toolbarHeight - 32.0;

    leftPosition = leftPosition.clamp(0.0, screenSize.width - toolbarWidth);
    topPosition = topPosition.clamp(0.0, screenSize.height - toolbarHeight);

    return Stack(
      children: [
        Positioned(
          left: leftPosition,
          top: topPosition,
          child: Toolbar(
            toolbarWidth: toolbarWidth,
            toolbarHeight: toolbarHeight,
            context: context,
            delegate: delegate,
            customColors: customColors,
            readingData: readingData, // 추가: 현재 읽기 데이터를 전달
          ),
        ),
      ],
    );
  }
}
