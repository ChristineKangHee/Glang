/// File: notification_page.dart
/// Purpose: 알림 탭별 내용을 표시하고, 데이터 필터링 및 새로고침 기능을 제공하는 화면 구현
/// Author: 박민준
/// Created: 2025-01-03
/// Last Modified: 2025-01-07 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/notification_viewmodel.dart';
import '../../../model/notification_item.dart';
import '../../../util/notification_util.dart';
import '../../components/custom_app_bar.dart';
import 'components/notification_tab_bar.dart';
import 'components/notification_item_widget.dart';

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
    _tabController = TabController(length: 5, vsync: this, animationDuration: Duration.zero); // 5개의 탭
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final textStyle = body_medium_semi(context).copyWith(color: customColors.neutral30 ?? Colors.grey);

    // 탭별로 데이터를 필터링 및 정렬
    final allNotifications = NotificationUtil.sortByDate(notifications);
    final unreadNotifications = NotificationUtil.filterUnread(allNotifications);
    final studyNotifications = allNotifications.where((n) => n.category == '코스').toList();
    final rewardNotifications = allNotifications.where((n) => n.category == '보상').toList();
    final systemNotifications = allNotifications.where((n) => n.category == '시스템').toList();

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "notification_title",
        bottom: NotificationTabBar(tabController: _tabController),
      ),
      body: SafeArea(
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            _buildRefreshableList(allNotifications, textStyle), // 전체 알림
            _buildRefreshableList(unreadNotifications, textStyle), // 읽지 않은 알림
            _buildRefreshableList(studyNotifications, textStyle), // 코스 관련 알림
            _buildRefreshableList(rewardNotifications, textStyle), // 보상 관련 알림
            _buildRefreshableList(systemNotifications, textStyle), // 시스템 알림
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshableList(List<NotificationItem> items, TextStyle style) {
    return RefreshIndicator(
      onRefresh: ref.read(notificationProvider.notifier).fetchNotifications,
      child: items.isEmpty
          ? Center(
        child: Text(
          "받은 알림이 없어요",
          style: style,
        ),
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // 스크롤 가능하도록 설정
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return NotificationItemWidget(
            title: item.title,
            description: item.description,
            date: item.date,
            category: item.category,
            isRead: item.isRead,
          );
        },
      ),
    );
  }

}
