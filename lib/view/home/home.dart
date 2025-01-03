/// File: home.dart
/// Purpose: 메인 화면
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'package:readventure/viewmodel/theme_controller.dart';

import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../components/custom_app_bar.dart';

class MyHomePage extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_Logo(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appState?.email ?? 'No User Logged In', // 사용자 이메일 표시
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(appStateProvider.notifier).clearUser(); // 사용자 로그아웃
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                context.setLocale(const Locale('ko')); // 한국어로 전환
              },
              child: const Text('Switch to Korean'),
            ),
            ElevatedButton(
              onPressed: () {
                context.setLocale(const Locale('en')); // 영어로 전환
              },
              child: const Text('Switch to English'),
            ),
            ElevatedButton(
              onPressed: showNotification,
              child: Text('Show Notification'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(), // 네비게이션 바
    );
  }
}
