/// File: login_main.dart
/// Purpose: Google 로그인을 위한 로그인 화면 구현 및 별명 설정 또는 홈 화면으로의 네비게이션 처리
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider.notifier);

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            authController.signInWithGoogle(
              onNicknameRequired: () {
                Navigator.pushReplacementNamed(context, '/nickname');
              },
              onHome: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            );
          },
          child: const Text('Google 로그인'),
        ),
      ),
    );
  }
}
