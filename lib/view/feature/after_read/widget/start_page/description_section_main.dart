/*

DescriptionSection(
  customColors: customColors, // 필수: CustomColors 전달
  items: [
    {
      "icon": Icons.import_contacts, // 사용자 지정 아이콘
      "text": "원문을 보려면 책 아이콘을 클릭하세요!",
    },
    {
      "icon": Icons.access_time_filled, // 사용자 지정 아이콘
      "text": "학습을 시작하면 타이머가 작동해요!",
    },
  ],
),

 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
    required this.customColors,
    this.items = const [
      {
        "icon": Icons.import_contacts,
        "text": "원문을 보려면 책 아이콘을 클릭하세요!",
      },
      {
        "icon": Icons.access_time_filled,
        "text": "미션을 시작하면 타이머가 작동해요!",
      },
    ],
  });

  final CustomColors customColors;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(48.w, 0, 0, 0),
      child: Column(
        children: items.map((item) => _buildRow(context, item)).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            item["icon"],
            color: customColors.primary40,
            size: 28,
          ),
          SizedBox(width: 12.w),
          Text(
            item["text"],
            style: body_small(context),
          ),
        ],
      ),
    );
  }
}
