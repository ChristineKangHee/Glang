/// File: notification_item.dart
/// Purpose: 알림 데이터를 정의하는 모델 클래스, 알림 제목, 설명, 날짜 및 읽음 상태를 관리
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

class NotificationItem {
  final String title;
  final String description;
  final DateTime date;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
    this.isRead = false,
  });
}
