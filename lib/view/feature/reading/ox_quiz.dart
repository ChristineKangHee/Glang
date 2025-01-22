import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_button.dart';

class OxQuiz extends StatefulWidget {
  final OxQuestion question;
  final Function(bool) onAnswerSelected;
  final bool? userAnswer; // 추가: 이전 답안 표시

  OxQuiz({required this.question, required this.onAnswerSelected, this.userAnswer});


  @override
  _OxQuizState createState() => _OxQuizState();
}

class _OxQuizState extends State<OxQuiz> {
  List<bool> userAnswers = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    // 초기 상태에 userAnswer 반영
    if (widget.userAnswer != null) {
      setState(() {
        if (userAnswers.length == 0) {
          userAnswers.add(widget.userAnswer!);
        } else {
          userAnswers[currentQuestionIndex] = widget.userAnswer!;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // Ensure default color is assigned if customColors are null
    Color successColor = customColors.success ?? Colors.green;
    Color errorColor = customColors.error ?? Colors.red;
    Color neutralColor = customColors.neutral100 ?? Colors.grey;
    Color neutralBorderColor = customColors.neutral80 ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
          side: BorderSide(
        width: 2,
        color: customColors.neutral90 ?? Colors.grey,
      ),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '퀴즈',
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.question.paragraph,
                style: body_small_semi(context).copyWith(
                  color: customColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Replacing Row with your custom design
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userAnswers.length <= currentQuestionIndex) {
                        widget.onAnswerSelected(true); // 'O' answer
                        setState(() {
                          userAnswers.add(true);
                        });
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1, // 1:1 aspect ratio
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: userAnswers.length > currentQuestionIndex &&
                              userAnswers[currentQuestionIndex] == true
                              ? (widget.question.correctAnswer
                              ? customColors.success40
                              : customColors.error40)
                              : customColors.neutral100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: userAnswers.length > currentQuestionIndex &&
                                userAnswers[currentQuestionIndex] == true
                                ? (widget.question.correctAnswer
                                ? customColors.success??Colors.green
                                : customColors.error??Colors.red)
                                : customColors.neutral80??neutralBorderColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle_outlined,
                            color: successColor,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userAnswers.length <= currentQuestionIndex) {
                        widget.onAnswerSelected(false); // 'X' answer
                        setState(() {
                          userAnswers.add(false);
                        });
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1, // 1:1 aspect ratio
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: userAnswers.length > currentQuestionIndex &&
                              userAnswers[currentQuestionIndex] == false
                              ? (!widget.question.correctAnswer
                              ? customColors.success40
                              : customColors.error40)
                              : neutralColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: userAnswers.length > currentQuestionIndex &&
                                userAnswers[currentQuestionIndex] == false
                                ? (!widget.question.correctAnswer
                                ? customColors.success??Colors.green
                                : customColors.error??Colors.red)
                                : customColors.neutral80??neutralBorderColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: customColors.error,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
