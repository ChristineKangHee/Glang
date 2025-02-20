// user_photo_url_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Provider: 현재 사용자의 프로필 사진 URL을 관리하는 상태 프로바이더
final userPhotoUrlProvider =
StateNotifierProvider<UserPhotoUrlNotifier, String?>(
      (ref) => UserPhotoUrlNotifier(),
);

class UserPhotoUrlNotifier extends StateNotifier<String?> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  late final StreamSubscription<User?> _authSubscription; // 사용자 인증 상태 구독

  UserPhotoUrlNotifier() : super(null) {
    // Firebase 인증 상태(authStateChanges())를 구독하여 로그인/로그아웃 감지
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // 로그인한 경우, 사용자 정보를 새로고침하고 최신 프로필 사진 URL을 가져옴
        await user.reload();
        state = user.photoURL;
      } else {
        // 로그아웃한 경우, 상태를 초기화 (null)
        state = null;
      }
    });
  }

  // 사용자의 프로필 사진 URL을 강제로 새로고침하는 메서드
  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      state = user.photoURL;
    }
  }

  // 프로필 사진 URL을 수동으로 업데이트하는 메서드
  void updatePhotoUrl(String? newUrl) {
    state = newUrl;
  }

  @override
  void dispose() {
    // 구독을 취소하여 메모리 누수를 방지
    _authSubscription.cancel();
    super.dispose();
  }
}
