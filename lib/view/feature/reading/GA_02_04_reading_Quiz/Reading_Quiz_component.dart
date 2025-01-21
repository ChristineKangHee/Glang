import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/custom_button.dart';

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

class QuizComponent extends StatefulWidget {
  final Question question;
  final List<dynamic> userAnswers;
  final int currentQuestionIndex;
  final Function(int) onAnswerSelected;

  const QuizComponent({
    Key? key,
    required this.question,
    required this.userAnswers,
    required this.currentQuestionIndex,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  _QuizComponentState createState() => _QuizComponentState();
}

class _QuizComponentState extends State<QuizComponent> {
  void _handleAnswer(int selectedAnswerIndex) {
    if (widget.userAnswers.length <= widget.currentQuestionIndex) {
      widget.onAnswerSelected(selectedAnswerIndex);
      _showResultDialog(selectedAnswerIndex);
    }
  }

  void _showResultDialog(int selectedAnswerIndex) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isCorrect = selectedAnswerIndex == widget.question.correctAnswerIndex;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: QuizResultDialog(
          isCorrect: isCorrect,
          explanation: widget.question.explanation,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
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
          ...List.generate(
            widget.question.options.length,
                (index) => GestureDetector(
              onTap: () {
                if (widget.userAnswers.length <= widget.currentQuestionIndex) {
                  _handleAnswer(index);
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.userAnswers.length > widget.currentQuestionIndex &&
                      widget.userAnswers[widget.currentQuestionIndex] == index
                      ? (index == widget.question.correctAnswerIndex
                      ? customColors.success40
                      : customColors.error40)
                      : customColors.neutral100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.userAnswers.length > widget.currentQuestionIndex &&
                        widget.userAnswers[widget.currentQuestionIndex] == index
                        ? (index == widget.question.correctAnswerIndex
                        ? customColors.success ?? Colors.green
                        : customColors.error ?? Colors.red)
                        : customColors.neutral80 ?? Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  widget.question.options[index],
                  style: body_small(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultDialog extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onClose;

  const QuizResultDialog({
    Key? key,
    required this.isCorrect,
    required this.explanation,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              textAlign: TextAlign.left,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          explanation,
          style: body_small(context).copyWith(
            color: customColors.neutral30,
          ),
        ),
        const SizedBox(height: 20),
        ButtonPrimary(
          function: onClose,
          title: '완료',
        ),
      ],
    );
  }
}
