import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/stage_data.dart';
import 'package:readventure/view/feature/reading/result_dialog.dart';
import 'package:readventure/view/feature/reading/GA_02_02_subjective/subjective_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_mcq/mcq_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02_04_reading_Quiz_ox/ox_quiz.dart';
import 'package:readventure/view/feature/reading/GA_02/toolbar_component.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../after_read/choose_activities.dart';

class RdMain extends StatefulWidget {
  final int stageIndex; // 선택된 스테이지 인덱스

  RdMain({required this.stageIndex});

  @override
  _RdMainState createState() => _RdMainState();
}

class _RdMainState extends State<RdMain> with SingleTickerProviderStateMixin {
  late StageData currentStage; // 현재 선택된 스테이지 데이터

  bool _showOxQuiz = false;
  bool _showMcqQuiz = false;

  int currentMcqQuestionIndex = 0;
  int currentOxQuestionIndex = 0;
  List<int> mcqUserAnswers = [];
  List<bool> oxUserAnswers = [];

  bool mcqCompleted = false;
  bool oxCompleted = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    currentStage = stages[widget.stageIndex]; // 현재 선택된 스테이지 데이터 불러오기

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

  // MCQ 퀴즈 정답 체크
  void checkMcqAnswer(int selectedIndex) {
    final question = currentStage.mcqQuestions[currentMcqQuestionIndex];
    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    setState(() {
      mcqUserAnswers.add(selectedIndex);
      mcqCompleted = true;
    });

    ResultDialog.show(context, isCorrect, question.explanation, () {
      setState(() {
        _showMcqQuiz = false;
        _animationController.reverse();
      });
    });
  }

  // OX 퀴즈 정답 체크
  void checkOxAnswer(bool selectedAnswer) {
    final question = currentStage.oxQuestions[currentOxQuestionIndex];
    bool isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      oxUserAnswers.add(selectedAnswer);
      oxCompleted = true;
    });

    ResultDialog.show(context, isCorrect, question.explanation, () {
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

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: CustomAppBar_2depth_8(title: currentStage.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 본문 1
            SelectableText(
              currentStage.content.split('\n\n')[0], // 첫 번째 본문
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors),
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
                      question: currentStage.mcqQuestions[currentMcqQuestionIndex],
                      onAnswerSelected: checkMcqAnswer,
                      userAnswer: mcqUserAnswers.isNotEmpty
                          ? mcqUserAnswers[currentMcqQuestionIndex]
                          : null,
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 본문 2
            SelectableText(
              currentStage.content.split('\n\n')[1], // 두 번째 본문
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors),
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
                      question: currentStage.oxQuestions[currentOxQuestionIndex],
                      onAnswerSelected: checkOxAnswer,
                      userAnswer: oxUserAnswers.isNotEmpty
                          ? oxUserAnswers[currentOxQuestionIndex]
                          : null,
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 본문 3
            SelectableText(
              currentStage.content.split('\n\n')[2], // 세 번째 본문
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              selectionControls: Read_Toolbar(customColors: customColors),
            ),

            const SizedBox(height: 40),

            // 📌 '읽기 완료' 버튼
            ButtonPrimary_noPadding(
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: 'LearningActivitiesPage'),
                    builder: (context) => LearningActivitiesPage(),
                  ),
                );
              },
              title: "읽기 완료",
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
      child: Icon(Icons.star, color: customColors.secondary, size: 14),
    );
  }
}



// 텍스트 선택 툴바를 구현한 클래스
class Read_Toolbar extends MaterialTextSelectionControls {
  final customColors;

  Read_Toolbar({required this.customColors});

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

    // Get the screen size to limit the toolbar's position
    final screenSize = MediaQuery.of(context).size;

    // Calculate the ideal position for the toolbar
    double leftPosition = (endpoints.first.point.dx + endpoints.last.point.dx) / 2 - toolbarWidth / 2+16;
    double topPosition = endpoints.first.point.dy + globalEditableRegion.top - toolbarHeight - 32.0;

    // Ensure the toolbar stays within the screen boundaries (left, top, and right)
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
          ),
        ),
      ],
    );
  }
}