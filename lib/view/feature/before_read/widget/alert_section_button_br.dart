/// File: alert_section_button_br.dart
/// Purpose: 학습 진행 중 알림 섹션에서 "다시 쓰기" 및 "글 읽기" 버튼을 제공하는 위젯
/// Author: 박민준
/// Created: 2025-01-0?
/// Last Modified: 2025-02-05 by 박민준

import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';

import '../../../../theme/font.dart';
import '../../reading/GA_02/RD_before.dart';

class AlertSectionButtonBr extends StatelessWidget {
  const AlertSectionButtonBr({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: ShapeDecoration(
              color: customColors.neutral90,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "다시 쓰기",
                style: body_small_semi(context).copyWith(color: customColors.neutral60),
              ),
            ),
          ),
        ),
        SizedBox(width: 8), // Optional: Add space between the two buttons
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: ShapeDecoration(
              color: customColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RdBefore()),
                );
              },
              child: Text(
                "글 읽기",
                style: body_small_semi(context).copyWith(color: customColors.neutral100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
