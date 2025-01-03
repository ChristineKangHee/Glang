/// File: notification_viewmodel.dart
/// Purpose: 알림 상태를 관리하며 알림 추가 및 읽음 상태 업데이트 기능을 제공
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/notification_item.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier() : super([]);

  void addNotification(NotificationItem item) {
    state = [...state, item];
  }

  void markAsRead(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          NotificationItem(
            title: state[i].title,
            description: state[i].description,
            date: state[i].date,
            isRead: true,
          )
        else
          state[i],
    ];
  }
}
