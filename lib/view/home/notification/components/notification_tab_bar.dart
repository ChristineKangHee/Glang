/// File: notification_tab_bar.dart
/// Purpose: 알림 탭 화면에서 사용할 커스터마이즈된 TabBar 위젯을 제공하여 탭 전환 및 스타일을 관리
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';

import '../../../../theme/theme.dart';

class NotificationTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const NotificationTabBar({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return TabBar(
      controller: tabController,
      isScrollable: true,
      indicator: BoxDecoration(
        color: customColors.black, // 선택된 탭의 배경색
        borderRadius: BorderRadius.circular(12),
      ),
      tabAlignment: TabAlignment.start,
      labelColor: customColors.white, // 선택된 탭의 텍스트 색상
      unselectedLabelColor: customColors.neutral60, // 선택되지 않은 탭의 텍스트 색상
      labelStyle: body_small_semi(context), // 선택된 텍스트 스타일
      unselectedLabelStyle: body_small_semi(context), // 선택되지 않은 텍스트 스타일
      tabs: List.generate(tabController.length, (index) {
        // 개별 탭 상태에 따라 스타일 적용
        final isSelected = tabController.index == index;
        return _buildTab(
          context,
          tabController,
          text: ['전체', '안읽음', '학습', '보상', '시스템'][index],
          isSelected: isSelected,
        );
      }),
    );
  }

  Widget _buildTab(BuildContext context, TabController controller, {required String text, required bool isSelected}) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      width: 100, // 고정 너비
      height: 40, // 고정 높이
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? customColors.black : Colors.transparent, // 선택된 탭 배경색
        borderRadius: BorderRadius.circular(12), // 둥근 모서리
        border: isSelected
            ? null // 선택된 탭에는 border 제거
            : Border.all(color: customColors.neutral60!), // 선택되지 않은 탭의 border 색상
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: isSelected
            ? body_small_semi(context).copyWith(color: customColors.white) // 선택된 텍스트 스타일
            : body_small_semi(context), // 선택되지 않은 텍스트 스타일
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48); // TabBar 높이 설정
}
