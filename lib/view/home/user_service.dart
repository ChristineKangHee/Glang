import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore에서 사용자 이름 가져오기
  Future<String?> getUserName(String userId) async {
    try {
      // Firestore의 users/{uid} 경로에서 데이터 가져오기
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // 사용자 이름 반환
        return userDoc.data()?['nickname'] as String?;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }
}

class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null);

  final UserService _userService = UserService();

  Future<void> fetchUserName(String userId) async {
    // 만약 state가 이미 존재하면, 굳이 Firestore 안 불러오고 건너뛸 수도 있음
    if (state != null) {
      return; // 이미 사용자 이름이 있으므로 재조회하지 않음
    }
    // 처음 불러올 때만 Firestore 호출
    state = await _userService.getUserName(userId);
  }
}

final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});
