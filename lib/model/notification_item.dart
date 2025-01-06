/// File: notification_item_widget.dart
/// Purpose: 알림 데이터를 정의하는 모델 클래스, 알림 제목, 설명, 날짜, 카테고리 및 읽음 상태를 관리
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

class NotificationItem {
  final String title;
  final String description;
  final DateTime date;
  final String category; // 새로 추가된 속성
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
    required this.category, // 생성자에 포함
    this.isRead = false,
  });
}