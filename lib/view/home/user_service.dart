// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

/// 2. 유저 닉네임을 StateNotifier로 관리
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null);

  final UserService _userService = UserService();

  /// Firestore에서 닉네임을 한 번 불러오는 메서드
  Future<void> fetchUserName(String userId) async {
    // 이미 닉네임이 state에 있다면, 재조회하지 않도록 처리 (선택 사항)
    if (state != null) {
      // 이미 값이 있으면 그냥 스킵 (원하면 지워도 됨)
      return;
    }

    // 처음 불러올 때만 Firestore 호출
    state = await _userService.getUserName(userId);
  }
}

/// 3. userNameProvider: 이 Provider를 구독하면, [UserNameNotifier]의 상태(닉네임)를 볼 수 있음
final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});
