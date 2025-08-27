import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'levelTest_mcq_quiz.dart';
import 'levelTest_ox_quiz.dart';
import 'levelTest_quiz_data.dart';
import 'levelTest_paragraph_analysis.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

int levelTestTime = 0;


class LevelTestRDMain extends ConsumerStatefulWidget {
  const LevelTestRDMain({super.key});

  @override
  _LevelTestRDMainState createState() => _LevelTestRDMainState();
}

class _LevelTestRDMainState extends ConsumerState<LevelTestRDMain> with SingleTickerProviderStateMixin {
  bool _showOxQuiz = false;
  bool _showMcqQuiz = false;

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

  void checkMcqAnswer(int selectedIndex, LevelTestMcqQuestion mcqQuiz) {
    final isCorrect = selectedIndex == mcqQuiz.correctAnswerIndex;

    setState(() {
      mcqUserAnswers = [selectedIndex];
      mcqCompleted = true;
      _showMcqQuiz = false;
    });
    _animationController.reverse();
  }

  void checkOxAnswer(bool selectedAnswer, LevelTestOxQuestion oxQuiz) {
    setState(() {
      oxUserAnswers = [selectedAnswer];
      oxCompleted = true;
      _showOxQuiz = false;
    });

    _animationController.reverse();
  }


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

  Future<void> _onSubmit() async {
    // 레벨테스트 결과 저장이 필요한 경우 여기서 처리
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LevelTestParagraphAnalysis(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: CustomAppBar_2depth_10(title: "레벨테스트"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mcqQuiz.paragraph,
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => toggleQuizVisibility('MCQ'),
              child: Column(
                children: [
                  _buildQuizButton(customColors, 'MCQ', mcqCompleted),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: _showMcqQuiz
                        ? levelTestmcqQuiz(
                      question: LevelTestMcqQuestion(
                        paragraph: mcqQuiz.paragraph,
                        options: mcqQuiz.options,
                        correctAnswerIndex: mcqQuiz.correctAnswerIndex,
                      ),
                      onAnswerSelected: (index) => checkMcqAnswer(index, mcqQuiz),
                      userAnswer: mcqUserAnswers.isNotEmpty ? mcqUserAnswers[0] : null,
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              oxQuiz.paragraph,
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => toggleQuizVisibility('OX'),
              child: Column(
                children: [
                  _buildQuizButton(customColors, 'OX', oxCompleted),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: _showOxQuiz
                        ? levelTestOxQuiz(
                      question: LevelTestOxQuestion(
                        paragraph: oxQuiz.paragraph,
                        correctAnswer: oxQuiz.correctAnswer,
                      ),
                      onAnswerSelected: (answer) => checkOxAnswer(answer, oxQuiz),
                      userAnswer: oxUserAnswers.isNotEmpty ? oxUserAnswers[0] : null,
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ButtonPrimary_noPadding(
              function: mcqCompleted && oxCompleted ? () => _onSubmit() : () {},
              title: "reading_complete".tr(),
              condition: mcqCompleted && oxCompleted ? "not null" : "null",
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
