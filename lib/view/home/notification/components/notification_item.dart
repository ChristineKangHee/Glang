/// File: notification_item.dart
/// Purpose: 알림 데이터를 표시하기 위한 위젯으로 제목, 설명, 날짜 및 읽음 여부를 시각적으로 표현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';

class NotificationItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final bool isRead;

  const NotificationItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text('${date.month}/${date.day}'),
    );
  }
}
