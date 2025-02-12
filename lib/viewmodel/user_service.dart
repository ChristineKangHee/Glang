/// File: user_service.dart
/// Purpose: 사용자 별명 상태 관리
/// Author: 윤은서
/// Created: 2025-02-12
/// Last Modified: 2025-02-12 by 윤은서

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 닉네임 상태 관리
class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier() : super('기본 닉네임'); // 기본 닉네임 설정

  void updateUserName(String newName) {
    state = newName; // 닉네임 업데이트
  }
}

// 닉네임을 관리하는 전역 Provider
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier();
});