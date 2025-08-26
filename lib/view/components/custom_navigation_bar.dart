/// File: custom_navigation_bar.dart
/// Purpose: 앱 하단 NavigationBar (L10N 적용)
/// Last Modified: 2025-08-26 by ChatGPT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가
import 'package:readventure/theme/font.dart';
import '../../viewmodel/navigation_controller.dart';
import '../../theme/theme.dart';

class CustomNavigationBar extends ConsumerWidget {
  const CustomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);
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
        selectedLabelStyle: body_xsmall_semi(context),
        unselectedLabelStyle: body_xsmall_semi(context).copyWith(color: customColors.neutral60),
        onTap: (index) => navigationController.navigateToIndex(context, index),
        items: <BottomNavigationBarItem>[ // ❌ const 제거
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: 'nav_home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.stars_rounded),
            label: 'nav_course'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article_rounded),
            label: 'nav_community'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: 'nav_mypage'.tr(),
          ),
        ],
      ),
    );
  }
}
