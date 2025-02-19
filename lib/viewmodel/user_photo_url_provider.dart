// user_photo_url_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Provider: 현재 사용자의 프로필 사진 URL을 관리합니다.
final userPhotoUrlProvider =
StateNotifierProvider<UserPhotoUrlNotifier, String?>(
      (ref) => UserPhotoUrlNotifier(),
);

class UserPhotoUrlNotifier extends StateNotifier<String?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSubscription;

  UserPhotoUrlNotifier() : super(null) {
    // authStateChanges()를 구독해서 로그인/로그아웃 상태 변경 시 자동 업데이트
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // 로그인 시, 최신 photoURL을 불러옵니다.
        await user.reload();
        state = user.photoURL;
      } else {
        // 로그아웃 시 상태를 초기화합니다.
        state = null;
      }
    });
  }

  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      state = user.photoURL;
    }
  }

  void updatePhotoUrl(String? newUrl) {
    state = newUrl;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
