import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'GA_02_04_reading_Quiz/Reading_Quiz_component.dart' as MC; // Multiple Choice Quiz
import 'GA_02_04_reading_Quiz_ox/Reading_ox_component.dart' as OX; // OX Quiz

class RdMain extends StatefulWidget {
  @override
  _RdMainState createState() => _RdMainState();
}

final List<dynamic> questions = [
  MC.Question(
    paragraph: '코코가 발견한 황금 열쇠는 무엇을 상징할까요?',
    options: ['새로운 모험', '코코의 일상', '사라진 보물', '우연한 발견'],
    correctAnswerIndex: 0,
    explanation: '황금 열쇠는 새로운 모험의 시작을 상징합니다.',
  ),
  OX.OXQuestion(
    paragraph: '코코는 열쇠가 무엇을 여는지 알아낼 수 있을까요?',
    correctAnswer: true,
    explanation: '코코의 열쇠는 새로운 발견으로 이어질 것입니다.',
  ),
];

class _RdMainState extends State<RdMain> with SingleTickerProviderStateMixin {
  bool _showQuiz = false;
  bool _isTextHighlighted = false;
  int currentQuestionIndex = 0;
  List<Object> userAnswers = [];
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

  // Toggle visibility of quiz and update the animation
  void toggleQuizVisibility() {
    setState(() {
      _showQuiz = !_showQuiz;
      _isTextHighlighted = !_isTextHighlighted;
      if (_showQuiz) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Check if the selected answer is correct
  void checkAnswer(Object selectedAnswer) {
    final currentQuestion = questions[currentQuestionIndex];
    bool isCorrect = false;

    if (currentQuestion is MC.Question) {
      isCorrect = selectedAnswer == currentQuestion.correctAnswerIndex;
    } else if (currentQuestion is OX.OXQuestion) {
      isCorrect = selectedAnswer == currentQuestion.correctAnswer;
    }

    setState(() {
      userAnswers.add(selectedAnswer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("텍스트 사이 문제 예시")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paragraph Text
            Text(
              '코코는 작은 시골 마을에 사는 강아지예요. 코코의 하루는 항상 비슷했어요...',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
            const SizedBox(height: 16),

            // First RichText with OX Quiz Button
            _buildTextWithQuizButton(
              text: '코코는 열쇠가 무엇을 여는지 알아내고 싶었어요...',
              isHighlighted: _isTextHighlighted,
              onTap: () {
                setState(() {
                  currentQuestionIndex = 1; // OX quiz
                  _showQuiz = !_showQuiz;
                  _animationController.forward();
                });
              },
              icon: Icons.check_circle_outline,
              customColors: customColors,
            ),

            // OX Quiz Component with animation (only show if OX quiz is selected)
            _buildQuizComponent(currentQuestion, currentQuestion is OX.OXQuestion
                ? OX.OXQuizComponent(
              question: currentQuestion,
              userAnswers: userAnswers.cast<bool>(),
              currentQuestionIndex: currentQuestionIndex,
              onAnswerSelected: checkAnswer,
            )
                : Container()),

            const SizedBox(height: 16),

            // Second RichText with MC Quiz Button
            _buildTextWithQuizButton(
              text: '“이게 뭐지?” 코코는 머리를 갸웃거리며 열쇠를 물었어요...',
              isHighlighted: _isTextHighlighted,
              onTap: () {
                setState(() {
                  currentQuestionIndex = 0; // MC quiz
                  _showQuiz = !_showQuiz;
                  _animationController.forward();
                });
              },
              icon: Icons.question_answer,
              customColors: customColors,
            ),

            // Multiple Choice Quiz Component with animation (only show if MC quiz is selected)
            _buildQuizComponent(currentQuestion, currentQuestion is MC.Question
                ? MC.QuizComponent(
              question: currentQuestion,
              userAnswers: userAnswers.cast<int>(),
              currentQuestionIndex: currentQuestionIndex,
              onAnswerSelected: checkAnswer,
            )
                : Container()),
          ],
        ),
      ),
    );
  }

  // Helper function for RichText with a Quiz Button
  Widget _buildTextWithQuizButton({
    required String text,
    required bool isHighlighted,
    required VoidCallback onTap,
    required IconData icon,
    required CustomColors customColors,
  }) {
    return RichText(
      text: TextSpan(
        style: reading_textstyle(context).copyWith(color: customColors.neutral0),
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              color: isHighlighted ? customColors.primary : customColors.neutral0,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: customColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: customColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for Quiz Components with animation
  Widget _buildQuizComponent(dynamic currentQuestion, Widget quizComponent) {
    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1.0,
      child: quizComponent,
    );
  }
}
