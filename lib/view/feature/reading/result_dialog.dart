import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import '../../../theme/font.dart';
import '../../components/custom_button.dart';

void showResultDialog(BuildContext context, bool isCorrect, String explanation, Function onCompleted) {
  final customColors = Theme.of(context).extension<CustomColors>()!;
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
            explanation,
            style: body_small(context).copyWith(
              color: customColors.neutral30,
            ),
          ),
          const SizedBox(height: 20),
          ButtonPrimary_noPadding(
            function: () {
              Navigator.pop(context);
              onCompleted();
            },
            title: '완료',
          ),
        ],
      ),
    ),
  );
}
