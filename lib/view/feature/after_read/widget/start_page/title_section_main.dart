/*

TitleSectionMain(
  title: "자신의 경험을",           // 첫번째 줄
  subtitle: "",                 // 두번째 줄 primary color
  subtitle2: "글로 표현해볼까요?",  // 두번째 줄 black color
  customColors: customColors,
),

 */
import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

class TitleSectionMain extends StatelessWidget {
  const TitleSectionMain({
    super.key,
    required this.customColors,
    required this.title,
    required this.subtitle,
    required this.subtitle2,
    this.icon = Icons.import_contacts,
  });

  final CustomColors customColors;
  final String title;
  final String subtitle;
  final String subtitle2;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: body_medium_semi(context),
        ),
      ],
    );
  }
}
