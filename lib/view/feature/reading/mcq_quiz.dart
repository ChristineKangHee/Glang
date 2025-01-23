import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class McqQuiz extends StatefulWidget {
  final McqQuestion question;
  final Function(int) onAnswerSelected;
  final int? userAnswer; // 추가: 이전 답안 표시

  McqQuiz({required this.question, required this.onAnswerSelected, this.userAnswer});


  @override
  _McqQuizState createState() => _McqQuizState();
}

class _McqQuizState extends State<McqQuiz> {
  int? selectedAnswerIndex;
  @override
  void initState() {
    super.initState();
    // userAnswer 값으로 초기 상태 설정
    if (widget.userAnswer != null) {
      setState(() {
        selectedAnswerIndex = widget.userAnswer;
      });
    }
  }
   // Track selected answer index

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

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
            Column(
              children: widget.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                // Check if this option is selected
                bool isSelected = selectedAnswerIndex == index;
                bool isCorrect = isSelected && index == widget.question.correctAnswerIndex;
                bool isIncorrect = isSelected && index != widget.question.correctAnswerIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswerIndex = index;
                    });
                    widget.onAnswerSelected(index);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? customColors.success40 // Correct answer
                          : isIncorrect
                          ? customColors.error40 // Incorrect answer
                          : customColors.neutral100, // Default color for unselected
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect
                            ? customColors.success ?? Colors.green
                            : customColors.error ?? Colors.red)
                            : customColors.neutral80 ?? Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      option,
                      style: body_small(context),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
