// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 1. Firestore에서 사용자 정보를 가져오는 Service 클래스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore에서 닉네임 중복 체크
  Future<bool> isNicknameAvailable(String nickname) async {
    final nicknameDoc = await _firestore.collection('nicknames').doc(nickname).get();
    return !nicknameDoc.exists; // 닉네임이 존재하지 않으면 사용 가능
  }

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

  /// Firestore에서 사용자 닉네임 변경
  Future<void> updateUserName(String userId, String newName, String oldName) async {
    try {
      final nicknameRef = _firestore.collection('nicknames').doc(newName);
      final userRef = _firestore.collection('users').doc(userId);
      final oldNicknameRef = _firestore.collection('nicknames').doc(oldName);

      await _firestore.runTransaction((transaction) async {
        // 새 닉네임이 사용 가능한지 다시 확인
        final nicknameSnapshot = await transaction.get(nicknameRef);
        if (nicknameSnapshot.exists) {
          throw Exception('이미 사용 중인 닉네임입니다.');
        }

        // 기존 닉네임 삭제
        transaction.delete(oldNicknameRef);

        // 새로운 닉네임 추가
        transaction.set(nicknameRef, {
          'uid': userId,
          'created_at': FieldValue.serverTimestamp(),
        });

        // 사용자 닉네임 업데이트
        transaction.update(userRef, {'nickname': newName});
      });

    } catch (e) {
      print('❌ Error updating user name: $e');
      throw Exception('닉네임 변경 실패');
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

  /// 닉네임 업데이트 (중복 체크 포함)
  Future<String?> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (user == null || state == null) return '오류: 사용자 정보가 없습니다.';

    final oldName = state!;

    // 닉네임 중복 체크
    final isAvailable = await _userService.isNicknameAvailable(newName);
    if (!isAvailable) {
      return '이미 사용 중인 닉네임입니다.';
    }

    // Firestore에서 닉네임 변경
    try {
      await _userService.updateUserName(user.uid, newName, oldName);
      state = newName;
      return null; // 성공
    } catch (e) {
      return '닉네임 변경 실패: ${e.toString()}';
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

/// 사용자의 이메일을 가져오는 Provider
final userEmailProvider = FutureProvider<String?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userSnapshot = await userRef.get();

  if (userSnapshot.exists && userSnapshot.data()!.containsKey('email')) {
    return userSnapshot.data()!['email'] as String;
  }
  return null; // 이메일 정보가 없을 경우
});

/// 사용자의 이름(name)을 가져오는 Provider
final userRealNameProvider = FutureProvider<String?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userSnapshot = await userRef.get();

  if (userSnapshot.exists && userSnapshot.data()!.containsKey('name')) {
    return userSnapshot.data()!['name'] as String;
  }
  return null; // 이름 정보가 없을 경우
});
