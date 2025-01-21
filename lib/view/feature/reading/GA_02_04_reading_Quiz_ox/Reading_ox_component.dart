import 'package:flutter/material.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/custom_button.dart';

class OXQuestion {
  final String paragraph;
  final bool correctAnswer;
  final String explanation;

  OXQuestion({
    required this.paragraph,
    required this.correctAnswer,
    required this.explanation,
  });
}

class OXQuizComponent extends StatefulWidget {
  final OXQuestion question;
  final List<bool> userAnswers;
  final int currentQuestionIndex;
  final Function(bool) onAnswerSelected;

  const OXQuizComponent({
    Key? key,
    required this.question,
    required this.userAnswers,
    required this.currentQuestionIndex,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  _OXQuizComponentState createState() => _OXQuizComponentState();
}

class _OXQuizComponentState extends State<OXQuizComponent>
    with SingleTickerProviderStateMixin {
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnswer(bool selectedAnswer) {
    if (widget.userAnswers.length <= widget.currentQuestionIndex) {
      widget.onAnswerSelected(selectedAnswer);
      _showResultDialog(selectedAnswer);
    }
  }

  void _showResultDialog(bool selectedAnswer) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isCorrect = selectedAnswer == widget.question.correctAnswer;

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

    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 27),
        decoration: ShapeDecoration(
          color: customColors.neutral100,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              color: customColors.neutral90 ?? Colors.grey,
            ),
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
            Row(
              children: [
                _buildAnswerButton(
                  context: context,
                  isSelected: widget.userAnswers.length > widget.currentQuestionIndex &&
                      widget.userAnswers[widget.currentQuestionIndex],
                  isCorrect: widget.question.correctAnswer,
                  label: 'O',
                  onTap: () => _handleAnswer(true),
                ),
                _buildAnswerButton(
                  context: context,
                  isSelected: widget.userAnswers.length > widget.currentQuestionIndex &&
                      !widget.userAnswers[widget.currentQuestionIndex],
                  isCorrect: !widget.question.correctAnswer,
                  label: 'X',
                  onTap: () => _handleAnswer(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required BuildContext context,
    required bool isSelected,
    required bool isCorrect,
    required String label,
    required VoidCallback onTap,
  }) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double iconSize = 40 + (_animation.value * 40);
              final double padding = 30 - (_animation.value * 10);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCorrect
                      ? customColors.success40
                      : customColors.error40)
                      : customColors.neutral100,
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
                child: Center(
                  child: Icon(
                    label == 'O'
                        ? (isCorrect
                        ? Icons.circle_outlined
                        : Icons.cancel_rounded)
                        : Icons.close_rounded, // For 'X', use a close icon.
                    color: label == 'O'
                        ? (isCorrect
                        ? customColors.success
                        : customColors.error)
                        : customColors.error, // Set the correct color
                    size: iconSize,
                  ),
                ),
              );
            },
          ),
        ),
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
