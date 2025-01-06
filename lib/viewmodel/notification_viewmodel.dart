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

  /// 알림 추가 메서드
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

  /// 알림 읽음 상태 업데이트 메서드
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

  /// 새로고침 시 알림 데이터를 업데이트하는 메서드
  Future<void> fetchNotifications() async {
    print("123");
    // 서버에서 데이터를 가져오거나 로컬에서 새로운 데이터를 추가하는 로직 작성
    await Future.delayed(const Duration(seconds: 2)); // 로딩 시간 시뮬레이션
    final newNotifications = [
      NotificationItem(
        title: '새로운 공지',
        description: '앱 기능이 추가되었습니다.',
        date: DateTime.now(),
        category: '시스템',
        isRead: false,
      ),
      NotificationItem(
        title: '오늘의 학습 알림',
        description: '학습 목표를 달성해 보세요!',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        category: '학습',
        isRead: false,
      ),
    ];

    // 기존 데이터에 새로운 알림 추가
    state = [...newNotifications, ...state];
  }
}
