import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/custom_button.dart';
import '../mcq_quiz.dart';
import '../ox_quiz.dart';
import '../quiz_data.dart';
import '../result_dialog.dart';
import '../subjective_quiz.dart';

class ReadingQuizUnifiedMain extends StatefulWidget {
  final List<OxQuestion> oxQuestions;
  final List<McqQuestion> mcqQuestions;

  ReadingQuizUnifiedMain({required this.oxQuestions, required this.mcqQuestions});

  @override
  _ReadingQuizUnifiedMainState createState() => _ReadingQuizUnifiedMainState();
}


class _ReadingQuizUnifiedMainState extends State<ReadingQuizUnifiedMain>
    with SingleTickerProviderStateMixin {
  bool _showOxQuiz = false;
  bool _showMcqQuiz = false;
  bool _showSubjectiveQuiz = false;
  int currentOxQuestionIndex = 0;
  int currentMcqQuestionIndex = 0;
  List<bool> oxUserAnswers = [];
  List<int> mcqUserAnswers = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _subjectiveController = TextEditingController();

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
    _subjectiveController.dispose();
    super.dispose();
  }

  void toggleQuizVisibility(String quizType) {
    setState(() {
      if (quizType == 'OX') {
        _showOxQuiz = !_showOxQuiz;
        _showMcqQuiz = false;
        _showSubjectiveQuiz = false;
      } else if (quizType == 'MCQ') {
        _showMcqQuiz = !_showMcqQuiz;
        _showOxQuiz = false;
        _showSubjectiveQuiz = false;
      } else {
        _showSubjectiveQuiz = !_showSubjectiveQuiz;
        _showOxQuiz = false;
        _showMcqQuiz = false;
      }
      if (_showOxQuiz || _showMcqQuiz || _showSubjectiveQuiz) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void checkOxAnswer(bool selectedAnswer) {
    final question = oxQuestions[currentOxQuestionIndex];
    bool isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      oxUserAnswers.add(selectedAnswer);
    });

    showResultDialog(context, isCorrect, question.explanation, () {
      setState(() {
        _showOxQuiz = false;
        _showMcqQuiz = false;
        _showSubjectiveQuiz = false;
        _animationController.reverse();
      });
    });
  }

  void checkMcqAnswer(int selectedIndex) {
    final question = mcqQuestions[currentMcqQuestionIndex];
    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    setState(() {
      mcqUserAnswers.add(selectedIndex);
    });

    showResultDialog(context, isCorrect, question.explanation, () {
      setState(() {
        _showOxQuiz = false;
        _showMcqQuiz = false;
        _showSubjectiveQuiz = false;
        _animationController.reverse();
      });
    });
  }

  void submitSubjectiveAnswer() {
    final answer = _subjectiveController.text.trim();
    _subjectiveController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('답변 제출 완료'),
        content: Text('주관식 답변이 제출되었습니다.\n\n답변: $answer'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text("텍스트 사이 문제 예시"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '코코는 작은 시골 마을에 사는 강아지예요. 코코의 하루는 항상 비슷했어요...',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: reading_textstyle(context).copyWith(
                  color: customColors.neutral0,
                ),
                children: [
                  TextSpan(
                    text: '“이게 뭐지?” 코코는 머리를 갸웃거리며 열쇠를 물었어요. ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('OX'),
                      child: _buildQuizButton(customColors, 'OX'),
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('MCQ'),
                      child: _buildQuizButton(customColors, 'MCQ'),
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('SUBJECTIVE'),
                      child: _buildQuizButton(customColors, 'SUBJECTIVE'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizeTransition(
              sizeFactor: _animation,
              child: _showOxQuiz
                  ? OxQuiz(question: oxQuestions[currentOxQuestionIndex], onAnswerSelected: checkOxAnswer)
                  : _showMcqQuiz
                  ? McqQuiz(question: mcqQuestions[currentMcqQuestionIndex], onAnswerSelected: checkMcqAnswer)
                  : _showSubjectiveQuiz
                  ? SubjectiveQuiz(controller: _subjectiveController, onSubmit: submitSubjectiveAnswer)
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(CustomColors customColors, String quizType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: customColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$quizType 퀴즈',
        style: reading_textstyle(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
