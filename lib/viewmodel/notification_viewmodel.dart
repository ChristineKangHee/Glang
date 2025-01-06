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
  NotificationNotifier() : super(_initialNotifications); // 초기 데이터 설정

  static final _initialNotifications = [
    NotificationItem(
      title: '새로운 업데이트',
      description: '앱이 버전 1.1로 업데이트되었습니다.',
      date: DateTime.now().subtract(Duration(days: 1)),
      category: '시스템',
      isRead: false,
    ),
    NotificationItem(
      title: '학습 알림',
      description: '오늘 학습 목표를 완료하세요!',
      date: DateTime.now().subtract(Duration(days: 2)),
      category: '학습',
      isRead: true,
    ),
    NotificationItem(
      title: '보상 지급',
      description: '로그인 보상을 받으세요!',
      date: DateTime.now(),
      category: '보상',
      isRead: false,
    ),
  ];

  void addNotification({
    required String title,
    required String description,
    required DateTime date,
    required String category,
    bool isRead = false,
  }) {
    state = [
      ...state,
      NotificationItem(
        title: title,
        description: description,
        date: date,
        category: category,
        isRead: isRead,
      ),
    ];
  }

  void markAsRead(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          NotificationItem(
            title: state[i].title,
            description: state[i].description,
            date: state[i].date,
            category: state[i].category,
            isRead: true,
          )
        else
          state[i],
    ];
  }
}



