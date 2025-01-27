/// File: custom_navigation_bar.dart
/// Purpose: 앱의 하단에 사용자 정의 NavigationBar를 제공하여 페이지 전환 및 상태 관리를 지원
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/navigation_controller.dart';
import '../../theme/theme.dart';

class CustomNavigationBar extends ConsumerWidget {
  const CustomNavigationBar({
    Key? key,
  }) : super(key: key);

  /*
  사용 방법:
  Scaffold 에서 아래와 같이 사용

  bottomNavigationBar: const CustomNavigationBar(),
   */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider); // 현재 선택된 인덱스 상태
    final navigationController = ref.read(navigationProvider.notifier);
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: customColors.neutral30,
        unselectedItemColor: customColors.neutral60,
        onTap: (index) => navigationController.navigateToIndex(context, index), // 페이지 전환
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_rounded),
            label: '코스',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
