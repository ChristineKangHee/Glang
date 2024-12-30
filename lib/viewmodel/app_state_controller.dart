/// File: app_state_controller.dart
/// Purpose: 사용자 인증 상태를 관리하고 전역 상태로 제공
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppStateController extends StateNotifier<User?> {
  AppStateController() : super(null);

  void setUser(User? user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

final appStateProvider = StateNotifierProvider<AppStateController, User?>((ref) {
  return AppStateController();
});
