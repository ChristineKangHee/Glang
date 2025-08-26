/// File: result_dialog.dart
/// Purpose: 읽기중 ox, 객관식 정답 화면 구현 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../theme/theme.dart';
import '../../../theme/font.dart';
import '../../components/custom_button.dart';

class ResultDialog extends StatelessWidget {
  final bool isCorrect;         // 정답 여부
  final String explanation;     // 정답/오답 설명 (이미 로컬라이즈된 String)
  final VoidCallback onCompleted;

  const ResultDialog({
    Key? key,
    required this.isCorrect,
    required this.explanation,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return AlertDialog(
      backgroundColor: customColors.neutral100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                isCorrect ? 'answer_correct'.tr() : 'answer_incorrect'.tr(),
                style: body_large_semi(context).copyWith(
                  color: isCorrect ? customColors.primary : customColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation, // RD_main에서 lx()로 이미 String 변환 완료
            style: body_small(context).copyWith(color: customColors.neutral30),
          ),
          const SizedBox(height: 20),
          ButtonPrimary_noPadding(
            function: () {
              Navigator.pop(context);
              onCompleted();
            },
            title: 'done'.tr(),
          ),
        ],
      ),
    );
  }

  static void show(
      BuildContext context,
      bool isCorrect,
      String explanation,
      VoidCallback onCompleted,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultDialog(
        isCorrect: isCorrect,
        explanation: explanation,
        onCompleted: onCompleted,
      ),
    );
  }
}
