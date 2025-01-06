/// File: notification_util.dart
/// Purpose: 알림 데이터를 포맷팅하고 읽지 않은 알림을 필터링하는 유틸리티 클래스
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:intl/intl.dart';
import '../model/notification_item.dart';

class NotificationUtil {
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd'); // 다국어 포맷 지원
    return formatter.format(date);
  }

  static List<NotificationItem> filterUnread(List<NotificationItem> items) {
    return items.where((item) => !item.isRead).toList();
  }

  static List<NotificationItem> sortByDate(List<NotificationItem> items) {
    items.sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
    return items;
  }
}
