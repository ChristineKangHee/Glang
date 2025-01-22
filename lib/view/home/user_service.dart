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

  void fetchUserName(String userId) async {
    state = await _userService.getUserName(userId); // 상태 업데이트
  }
}

final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});
