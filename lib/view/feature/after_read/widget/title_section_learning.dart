/*

  TitleSection_withIcon(
    customColors: Theme.of(context).extension<CustomColors>()!, // CustomColors 가져오기
    title: "글을 읽고 나만의 결말을 작성해보세요!",               // 제목
    subtitle: "<토끼 가족 이야기>",                           // 부제목
    author: "김댕댕",                                         // 작성자
    icon: Icons.book_outlined,                               // 아이콘 (기본값: Icons.import_contacts)
  ),

  TitleSection_withoutIcon(
    customColors: Theme.of(context).extension<CustomColors>()!, // CustomColors 가져오기
    title: "글을 읽고 나만의 결말을 작성해보세요!",               // 제목
    subtitle: "<토끼 가족 이야기>",                           // 부제목
    author: "김댕댕",                                         // 작성자
  ),
*/

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

class TitleSection_withIcon extends StatelessWidget {
  const TitleSection_withIcon({
    super.key,
    required this.customColors,
    required this.title,
    required this.subtitle,
    required this.author,
    this.icon = Icons.import_contacts_outlined,
  });

  final CustomColors customColors;
  final String title;
  final String subtitle;
  final String author;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: body_small_semi(context).copyWith(
                color: customColors.primary,
              ),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
                Text(
                  " | ",
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
                Text(
                  author,
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
              ],
            ),
          ],
        ),
        _buildIcon(customColors),
      ],
    );
  }

  Widget _buildIcon(CustomColors customColors) {
    return Container(
      width: 48,
      height: 48,
      decoration: const ShapeDecoration(
        color: Color(0xFF514FFF),
        shape: OvalBorder(),
      ),
      child: Icon(
        icon,
        color: customColors.neutral100,
        size: 24,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: body_small_semi(context).copyWith(
                color: customColors.primary,
              ),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
                Text(
                  " | ",
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
                Text(
                  author,
                  style: body_small(context)
                      .copyWith(color: customColors.neutral60),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
