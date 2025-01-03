/// File: settings_page.dart
/// Purpose: 사용자 설정 옵션(프로필, 알림, 언어, 테마, 로그아웃)을 제공하는 설정 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            onTap: () {
              // TODO: 알림 설정 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어 설정'),
            onTap: () {
              // TODO: 언어 설정 페이지로 이동

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
            },
          ),
        ],
      ),
    );
  }
}
