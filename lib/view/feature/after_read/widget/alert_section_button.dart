import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';

import '../../../../theme/font.dart';
import '../choose_activities.dart';

class AlertSectionButton extends StatelessWidget {
  const AlertSectionButton({
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
                // Navigator.popUntil(
                //   context,
                //       (route) => route.settings.name == 'LearningActivitiesPage',
                // );
                // 새로고침을 위해서 우선 땜빵용으로 이렇게 해두었다...
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LearningActivitiesPage()),
                );
              },
              child: Text(
                "완료",
                style: body_small_semi(context).copyWith(color: customColors.neutral100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
