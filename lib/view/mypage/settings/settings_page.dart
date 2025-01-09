/// File: settings_page.dart
/// Purpose: 사용자 설정 옵션(프로필, 알림, 언어, 테마, 로그아웃)을 제공하는 설정 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-09 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/app_state_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase 인증 상태 초기화
      ref.read(appStateProvider.notifier).clearUser(); // 전역 상태 초기화
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 로그인 화면으로 이동
    } catch (e) {
      print('로그아웃 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('프로필 설정'),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            onTap: () {
              // TODO: 알림 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/notification');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어 설정'),
            onTap: () {
              // TODO: 언어 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/language');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('테마 설정'),
            onTap: () {
              // TODO: 테마 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/theme');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              // TODO: 로그아웃 기능 구현
              _logout(context, ref);
            },
          ),
        ],
      ),
    );
  }
}
