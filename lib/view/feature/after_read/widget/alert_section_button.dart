import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';

class AlertSectionButton extends StatelessWidget {
  const AlertSectionButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 32.0,
            ),
            backgroundColor: customColors.neutral90,
            foregroundColor: customColors.neutral60,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("다시 쓰기"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 32.0,
            ),
            backgroundColor: customColors.primary,
            foregroundColor: customColors.neutral100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("완료"),
        ),
      ],
    );
  }
}
