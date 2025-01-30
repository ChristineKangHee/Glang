/// File: notification_item_widget.dart
/// Purpose: 알림 데이터를 표시하기 위한 위젯으로 제목, 설명, 날짜, 카테고리 및 읽음 여부를 시각적으로 표현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import '../../../../util/notification_util.dart';
import 'package:readventure/theme/font.dart';

class NotificationItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final String category; // 카테고리 추가
  final bool isRead;

  const NotificationItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.category, // 카테고리 추가
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return ListTile(
      contentPadding: EdgeInsets.all(16),
      tileColor: isRead ? customColors.white : customColors.primary10,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: body_xxsmall_semi(context).copyWith(color: customColors.neutral60),), // 날짜 포맷팅 적용
          Text(NotificationUtil.formatDate(date), style: body_xxsmall(context).copyWith(color: customColors.neutral60),), // 날짜 포맷팅 적용
          // if (!isRead)
          //   const Icon(Icons.circle, size: 8, color: Colors.red), // 읽지 않은 알림 표시
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(title, style: isRead ? body_small(context) : body_small_semi(context),),
          const SizedBox(height: 4,),
          Text(description, style: body_small(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    // 카테고리에 따른 아이콘 및 색상 결정
    switch (category) {
      case '코스':
        return const Icon(Icons.school, color: Colors.blue);
      case '보상':
        return const Icon(Icons.card_giftcard, color: Colors.green);
      case '시스템':
        return const Icon(Icons.settings, color: Colors.grey);
      default:
        return const Icon(Icons.notifications, color: Colors.orange);
    }
  }
}