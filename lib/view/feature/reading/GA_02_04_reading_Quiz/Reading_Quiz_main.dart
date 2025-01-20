import 'package:flutter/material.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/custom_button.dart';

class ReadingQuizMain extends StatefulWidget {
  @override
  _ReadingQuizMainState createState() => _ReadingQuizMainState();
}

class Question {
  final String paragraph;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.paragraph,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

// Sample quiz data
final List<Question> questions = [
  Question(
    paragraph: '코코가 발견한 황금 열쇠는 무엇을 상징할까요?',
    options: ['새로운 모험', '코코의 일상', '사라진 보물', '우연한 발견'],
    correctAnswerIndex: 0,
    explanation: '황금 열쇠는 새로운 모험의 시작을 상징합니다.',
  ),
];

class _ReadingQuizMainState extends State<ReadingQuizMain> with SingleTickerProviderStateMixin {
  bool _showQuiz = false; // Quiz visibility state
  bool _isTextHighlighted = false; // Text highlighting state
  int currentQuestionIndex = 0; // Current quiz index
  List<int> userAnswers = []; // Store user answers
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

  void checkAnswer(int selectedIndex) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final question = questions[currentQuestionIndex];
    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    setState(() {
      userAnswers.add(selectedIndex);
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
                    text: '“이게 뭐지?” 코코는 머리를 갸웃거리며 열쇠를 물었어요. ',
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
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.paragraph,
                    style: body_large(context),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    question.options.length,
                        (index) => GestureDetector(
                      onTap: () {
                        if (userAnswers.length <= currentQuestionIndex) {
                          checkAnswer(index);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: userAnswers.length > currentQuestionIndex &&
                              userAnswers[currentQuestionIndex] == index
                              ? (index == question.correctAnswerIndex
                              ? customColors.success40
                              : customColors.error40)
                              : customColors.neutral100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: userAnswers.length > currentQuestionIndex &&
                                userAnswers[currentQuestionIndex] == index
                                ? (index == question.correctAnswerIndex
                                ? customColors.success ?? Colors.green
                                : customColors.error ?? Colors.red)
                                : customColors.neutral80 ?? Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          question.options[index],
                          style: body_small(context),
                        ),
                      ),
                    ),
                  ),
                ],
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
