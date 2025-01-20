import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final CustomColors customColors;
  final double borderRadius;

  const CustomChip({
    Key? key,
    required this.label,
    required this.customColors,
    this.borderRadius = 14.0, // 기본 Radius 값
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: customColors.secondary60 ?? Colors.yellow),
      ),
      label: Text(
        label,
        style: body_small(context).copyWith(color: customColors.neutral30 ?? Colors.white),
      ),
      backgroundColor: customColors.secondary60 ?? Colors.yellow,
    );
  }
}
