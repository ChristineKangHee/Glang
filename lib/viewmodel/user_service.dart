// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 1. Firestore에서 사용자 정보를 가져오는 Service 클래스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore에서 사용자 이름(닉네임) 가져오기
  Future<String?> getUserName(String userId) async {
    try {
      // Firestore의 users/{uid} 경로에서 데이터 가져오기
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // 사용자 이름(닉네임) 반환
        return userDoc.data()?['nickname'] as String?;
      } else {
        print('❌ User not found');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user name: $e');
      return null;
    }
  }

  /// Firestore에서 사용자 닉네임 업데이트
  Future<void> updateUserName(String userId, String newName) async {
    try {
      await _firestore.collection('users').doc(userId).update({'nickname': newName});
    } catch (e) {
      print('❌ Error updating user name: $e');
    }
  }
}

/// 2. 유저 닉네임을 StateNotifier로 관리
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    fetchUserName();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// Firestore에서 닉네임을 한 번 불러오는 메서드
  Future<void> fetchUserName() async {
    final user = _auth.currentUser;
    // 이미 닉네임이 state에 있다면, 재조회하지 않도록 처리 (선택 사항)
    if (user?.uid != null) {
      final nickname = await _userService.getUserName(user!.uid);
      state = nickname ?? '';
    }
  }

  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (state != null) {
      await _userService.updateUserName(user!.uid, newName);
      state = newName;
    }
  }
}

/// 3. userNameProvider: 이 Provider를 구독하면, [UserNameNotifier]의 상태(닉네임)를 볼 수 있음
final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});


/// 사용자의 totalXP를 가져오는 Provider
final userXPProvider = FutureProvider<int>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userSnapshot = await userRef.get();

  if (userSnapshot.exists && userSnapshot.data()!.containsKey('totalXP')) {
    return userSnapshot.data()!['totalXP'] as int;
  }
  return 0; // 기본값
});
