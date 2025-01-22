import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import 'package:readventure/view/feature/reading/result_dialog.dart';
import 'package:readventure/view/feature/reading/subjective_quiz.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_app_bar.dart';
import '../after_read/choose_activities.dart';
import 'mcq_quiz.dart';
import 'ox_quiz.dart';

class RdMain extends StatefulWidget {
  final List<OxQuestion> oxQuestions;
  final List<McqQuestion> mcqQuestions;

  RdMain({required this.oxQuestions, required this.mcqQuestions});

  @override
  _RdMainState createState() => _RdMainState();
}


class _RdMainState extends State<RdMain> with SingleTickerProviderStateMixin {
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
  String? subjectiveAnswer; // 주관식 답변 저장

  // Track quiz completion status
  bool oxCompleted = false;
  bool mcqCompleted = false;
  bool subjectiveCompleted = false;

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

  void checkOxAnswer(bool selectedAnswer) {
    final question = widget.oxQuestions[currentOxQuestionIndex];
    bool isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      // 현재 인덱스에 답 저장
      if (oxUserAnswers.length > currentOxQuestionIndex) {
        oxUserAnswers[currentOxQuestionIndex] = selectedAnswer;
      } else {
        // 새로운 답 추가
        oxUserAnswers.add(selectedAnswer);
      }
      oxCompleted = true;
    });

    showResultDialog(context, isCorrect, question.explanation, () {
      setState(() {
        _showOxQuiz = false;
        _animationController.reverse();
      });
    });
  }

  void checkMcqAnswer(int selectedIndex) {
    final question = widget.mcqQuestions[currentMcqQuestionIndex];
    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    setState(() {
      // 현재 인덱스에 답 저장
      if (mcqUserAnswers.length > currentMcqQuestionIndex) {
        mcqUserAnswers[currentMcqQuestionIndex] = selectedIndex;
      } else {
        // 새로운 답 추가
        mcqUserAnswers.add(selectedIndex);
      }
      mcqCompleted = true;
    });

    showResultDialog(context, isCorrect, question.explanation, () {
      setState(() {
        _showMcqQuiz = false;
        _animationController.reverse();
      });
    });
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



  void submitSubjectiveAnswer() {
    final answer = _subjectiveController.text.trim();
    setState(() {
      subjectiveAnswer = answer; // Save the answer
      subjectiveCompleted = true; // Mark as completed
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('답변 제출 완료'),
        content: Text('주관식 답변이 제출되었습니다.\n\n답변: $answer'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              toggleQuizVisibility('SUBJECTIVE'); // Hide the quiz after submission
            },
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
      appBar: CustomAppBar_2depth_8(
        title: "읽기 도구의 필요성",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다.',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: reading_textstyle(context).copyWith(
                  color: customColors.neutral0,
                ),
                children: [
                  //ox 문제
                  TextSpan(
                    text: '기존의 교육 시스템은 주로 일률적인 교재와 평가 방식을 사용하며, 이는 학습 동기를 저하시킬 위험이 있다. ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('OX'),
                      child: Column(
                        children: [
                          _buildQuizButton(customColors, 'OX', oxCompleted),
                          SizeTransition(
                            sizeFactor: _animation,
                            child: _showOxQuiz
                                ? OxQuiz(
                              question: widget.oxQuestions[currentOxQuestionIndex],
                              onAnswerSelected: checkOxAnswer,
                              userAnswer: oxUserAnswers.length > currentOxQuestionIndex
                                  ? oxUserAnswers[currentOxQuestionIndex]
                                  : null,
                            )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //핵심 질문
                  TextSpan(
                    text: '또한, 읽기 과정에서 즉각적인 피드백을 제공하는 시스템이 부족하여 학습자는 자신의 약점이나 강점을 파악하기 어렵다.',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('SUBJECTIVE'),
                      child: Column(
                        children: [
                          _buildQuizButton(customColors, 'SUBJECTIVE', subjectiveCompleted),
                          SizeTransition(
                            sizeFactor: _animation,
                            child: _showSubjectiveQuiz
                                ? SubjectiveQuiz(
                              controller: _subjectiveController,
                              onSubmit: submitSubjectiveAnswer,
                              initialAnswer: subjectiveAnswer, // 초기 답변 전달
                              enabled: !subjectiveCompleted, // Disable if completed
                            )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //객관식
                  TextSpan(
                    text: '맞춤형 읽기 도구와 실시간 피드백 시스템은 학습자가 적합한 자료를 통해 능동적으로 읽기 능력을 향상시키고, 스스로 학습 과정을 조율할 수 있는 환경을 제공할 잠재력이 있다. 또한, 맞춤형 읽기 도구는 학습자의 수준과 흥미를 고려하여 적합한 자료를 제공할 수 있다.',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => toggleQuizVisibility('MCQ'),
                      child: Column(
                        children: [
                          _buildQuizButton(customColors, 'MCQ', mcqCompleted),
                          SizeTransition(
                            sizeFactor: _animation,
                            child: _showMcqQuiz
                                ? McqQuiz(
                              question: widget.mcqQuestions[currentMcqQuestionIndex],
                              onAnswerSelected: checkMcqAnswer,
                              userAnswer: mcqUserAnswers.length > currentMcqQuestionIndex
                                  ? mcqUserAnswers[currentMcqQuestionIndex]
                                  : null,
                            )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            ButtonPrimary(
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
            SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(CustomColors customColors, String quizType, bool isCompleted) {
    return Container(
      width: 30, // 버튼의 가로 크기
      height: 30, // 버튼의 세로 크기
      decoration: BoxDecoration(
        color: isCompleted ? customColors.primary20 : customColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center, // 아이콘을 중앙에 배치
      child: Icon(Icons.star, color: customColors.secondary, size: 14),
    );
  }
}
