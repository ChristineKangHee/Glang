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
