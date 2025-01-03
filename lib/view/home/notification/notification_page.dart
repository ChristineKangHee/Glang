/// File: notification_page.dart
/// Purpose: 알림 탭별 내용을 표시하고, 탭과 알림 데이터를 관리하는 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/notification_viewmodel.dart';
import '../../../model/notification_item.dart';
import '../../components/custom_app_bar.dart';
import 'components/notification_tab_bar.dart';
import 'components/notification_item.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_3(
        title: "notification_title",
        bottom: NotificationTabBar(tabController: _tabController),),
      body: TabBarView(
        controller: _tabController,
        children: [
          // _buildNotificationList(notifications),
          // _buildNotificationList(notifications.where((n) => !n.isRead).toList()),
          // _buildNotificationList(notifications.where((n) => n.isRead).toList()),
          Center(child: Text('전체 내용')),
          Center(child: Text('안읽음 내용')),
          Center(child: Text('학습 내용')),
          Center(child: Text('보상 내용')),
          Center(child: Text('시스템 내용')),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('알림이 없습니다.'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return NotificationItemWidget(
          title: item.title,
          description: item.description,
          date: item.date,
          isRead: item.isRead,
        );
      },
    );
  }
}
