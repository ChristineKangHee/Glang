import 'package:flutter/material.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../util/box_shadow_styles.dart';
import '../../../components/custom_button.dart';

class ReadingQuizOxMain extends StatefulWidget {
  @override
  _ReadingQuizOxMainState createState() => _ReadingQuizOxMainState();
}

class Question {
  final String paragraph;
  final bool correctAnswer; // OX 문제용 정답(boolean)
  final String explanation;

  Question({
    required this.paragraph,
    required this.correctAnswer,
    required this.explanation,
  });
}

// Sample quiz data
final List<Question> questions = [
  Question(
    paragraph: '코코가 발견한 황금 열쇠는 새로운 모험을 상징한다.',
    correctAnswer: true,
    explanation: '황금 열쇠는 새로운 모험의 시작을 상징합니다.',
  ),
];

class _ReadingQuizOxMainState extends State<ReadingQuizOxMain> with SingleTickerProviderStateMixin {
  bool _showQuiz = false; // Quiz visibility state
  bool _isTextHighlighted = false; // Text highlighting state
  int currentQuestionIndex = 0; // Current quiz index
  List<bool> userAnswers = []; // Store user answers
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

  void checkAnswer(bool selectedAnswer) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final question = questions[currentQuestionIndex];
    bool isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      userAnswers.add(selectedAnswer);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect ? customColors.primary : customColors.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? '정답입니다!' : '오답입니다.',
                  style: body_large_semi(context).copyWith(
                    color: isCorrect ? customColors.primary : customColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.explanation,
              style: body_small(context).copyWith(
                color: customColors.neutral30,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            ButtonPrimary(
              function: () {
                Navigator.pop(context);
                setState(() {
                  _showQuiz = false;
                  _isTextHighlighted = false; // Reset highlighting
                  _animationController.reverse();
                });
              },
              title: '완료',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final question = questions[currentQuestionIndex];

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
                    text: '코코는 열쇠가 무엇을 여는지 알아내고 싶었어요...',
                    style: TextStyle(
                      color: _isTextHighlighted
                          ? customColors.primary
                          : customColors.neutral0,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: toggleQuizVisibility,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: customColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.quiz, size: 16, color: customColors.secondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: _showQuiz
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 27),
                decoration: ShapeDecoration(
                  color: customColors.neutral100,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: customColors.neutral90 ?? Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centered the quiz title
                  children: [
                    Text(
                      '퀴즈',
                      textAlign: TextAlign.center, // This keeps the quiz title centered
                      style: body_small_semi(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft, // Aligns the paragraph to the left
                      child: Text(
                        question.paragraph,
                        style: body_small_semi(context).copyWith(
                          color: customColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (userAnswers.length <= currentQuestionIndex) {
                                checkAnswer(true);
                              }
                            },
                            child: AspectRatio(
                              aspectRatio: 1, // 1:1 비율 유지
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  final double iconSize = 40 + (_animation.value * 40); // Start at 40, expand by 40
                                  final double padding = 30 - (_animation.value * 10); // Start at 30, reduce by 10
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.all(padding),
                                    decoration: BoxDecoration(
                                      color: userAnswers.length > currentQuestionIndex &&
                                          userAnswers[currentQuestionIndex] == true
                                          ? (question.correctAnswer
                                          ? customColors.success40
                                          : customColors.error40)
                                          : customColors.neutral100,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: userAnswers.length > currentQuestionIndex &&
                                            userAnswers[currentQuestionIndex] == true
                                            ? (question.correctAnswer
                                            ? customColors.success ?? Colors.green
                                            : customColors.error ?? Colors.red)
                                            : customColors.neutral80 ?? Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.circle_outlined, color: customColors.success, size: iconSize),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (userAnswers.length <= currentQuestionIndex) {
                                checkAnswer(false);
                              }
                            },
                            child: AspectRatio(
                              aspectRatio: 1, // 1:1 비율 유지
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  final double iconSize = 40 + (_animation.value * 40); // Start at 40, expand by 40
                                  final double padding = 30 - (_animation.value * 10); // Start at 30, reduce by 10
                                  return Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.all(padding),
                                    decoration: BoxDecoration(
                                      color: userAnswers.length > currentQuestionIndex &&
                                          userAnswers[currentQuestionIndex] == false
                                          ? (!question.correctAnswer
                                          ? customColors.success40
                                          : customColors.error40)
                                          : customColors.neutral100,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: userAnswers.length > currentQuestionIndex &&
                                            userAnswers[currentQuestionIndex] == false
                                            ? (!question.correctAnswer
                                            ? customColors.success ?? Colors.green
                                            : customColors.error ?? Colors.red)
                                            : customColors.neutral80 ?? Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.close_rounded, color: customColors.error, size: iconSize),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Text(
              '코코는 열쇠가 무엇을 여는지 알아내고 싶었어요...',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
          ],
        ),
      ),
    );
  }
}
