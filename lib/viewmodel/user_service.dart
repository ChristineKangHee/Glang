/// File: user_service.dart
/// Purpose: 사용자 별명 상태 관리
/// Author: 윤은서
/// Created: 2025-02-12
/// Last Modified: 2025-02-12 by 윤은서

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 사용자 별명 관리
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    fetchUserName();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase에서 사용자 이름 가져오기
  Future<void> fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      state = doc.data()?['nickname'] ?? 'null';
    }
  }

  // 별명 업데이트 (Firebase에 저장)
  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'nickname': newName});
      state = newName;
    }
  }
}

// Riverpod Provider
final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});