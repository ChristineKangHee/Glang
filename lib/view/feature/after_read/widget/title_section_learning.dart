import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../After_Read_Content.dart';

class TitleSection_withIcon extends StatelessWidget {
  const TitleSection_withIcon({
    super.key,
    required this.customColors,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.stageId, // ✅ stageId 추가
    required this.subdetailTitle, // ✅ subdetailTitle 추가
    this.icon = Icons.import_contacts_outlined,
  });

  final CustomColors customColors;
  final String title;
  final String subtitle;
  final String author;
  final String stageId; // ✅ 추가된 매개변수
  final String subdetailTitle; // ✅ 추가된 매개변수
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: body_small_semi(context).copyWith(
                  color: customColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subtitle,
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                    TextSpan(
                      text: " | ",
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                    TextSpan(
                      text: author,
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildIcon(customColors, context),
      ],
    );
  }

  Widget _buildIcon(CustomColors customColors, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AfterReadContent(
              stageId: stageId, // ✅ stageId 전달
              subdetailTitle: subdetailTitle, // ✅ subdetailTitle 전달
            ),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          color: customColors.primary,
          shape: const OvalBorder(),
        ),
        child: Icon(
          icon,
          color: customColors.neutral100,
          size: 24,
        ),
      ),
    );
  }
}

class TitleSection_withoutIcon extends StatelessWidget {
  const TitleSection_withoutIcon({
    super.key,
    required this.customColors,
    required this.title,
    required this.subtitle,
    required this.author,
  });

  final CustomColors customColors;
  final String title;
  final String subtitle;
  final String author;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 텍스트의 수직 정렬
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: body_small_semi(context).copyWith(
                  color: customColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subtitle,
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                    TextSpan(
                      text: " | ",
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                    TextSpan(
                      text: author,
                      style: body_small(context).copyWith(color: customColors.neutral60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
