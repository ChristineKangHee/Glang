// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore에서 사용자 정보를 관리하는 서비스 클래스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore에서 닉네임 중복 체크
  Future<bool> isNicknameAvailable(String nickname) async {
    final nicknameDoc = await _firestore.collection('nicknames').doc(nickname).get();
    return !nicknameDoc.exists; // 닉네임이 존재하지 않으면 사용 가능
  }

  /// Firestore에서 사용자 이름(닉네임) 가져오기
  Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data()?['nickname'] as String?;
      } else {
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
        final nicknameSnapshot = await transaction.get(nicknameRef);
        if (nicknameSnapshot.exists) {
          throw Exception('이미 사용 중인 닉네임입니다.');
        }

        transaction.delete(oldNicknameRef);
        transaction.set(nicknameRef, {'uid': userId, 'created_at': FieldValue.serverTimestamp()});
        transaction.update(userRef, {'nickname': newName});
      });

    } catch (e) {
      print('❌ Error updating user name: $e');
      throw Exception('닉네임 변경 실패');
    }
  }

  /// 🔹 Firestore 서브컬렉션 삭제 함수
  Future<void> deleteSubCollection(CollectionReference collectionRef) async {
    final querySnapshot = await collectionRef.get();
    final batch = _firestore.batch();

    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  /// 🔹 사용자 계정 삭제 (Firestore & Authentication)
  Future<void> deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userRef = _firestore.collection('users').doc(userId);

        // 1. 사용자 데이터 가져오기 (닉네임 포함)
        final userSnapshot = await userRef.get();
        final nickname = userSnapshot.data()?['nickname'];

        // 2. 서브컬렉션 삭제 (attendance, progress)
        await deleteSubCollection(userRef.collection('attendance'));
        await deleteSubCollection(userRef.collection('progress'));

        // 3. 닉네임 컬렉션 삭제
        if (nickname != null && nickname.toString().isNotEmpty) {
          await _firestore.collection('nicknames').doc(nickname).delete();
        }

        // 4. 사용자 문서 삭제
        await userRef.delete();

        // 5. Firebase Authentication에서 계정 삭제
        await user.delete();

        // 6. 상태 초기화 및 메시지, 네비게이션 처리
        ref.read(userNameProvider.notifier).state = "";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("탈퇴가 완료되었습니다. 다음에 또 만나요.")),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 중 오류가 발생했습니다: $e")),
      );
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


Future<void> updateUserCourse(String userId, String newCourse) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  await userRef.update({'currentCourse': newCourse});
}

final userCourseProvider = FutureProvider<String>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return '미설정';
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (userDoc.exists) {
    final data = userDoc.data();
    return data?['currentCourse'] as String? ?? '미설정';
  }
  return '미설정';
});
