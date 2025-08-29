// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readventure/viewmodel/user_photo_url_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../restart_widget.dart';

/// Firestore에서 사용자 정보를 관리하는 서비스 클래스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore에서 닉네임 중복 체크
  Future<bool> isNicknameAvailable(String nickname) async {
    final nicknameDoc =
    await _firestore.collection('nicknames').doc(nickname).get();
    return !nicknameDoc.exists; // 닉네임이 존재하지 않으면 사용 가능
  }

  /// Firestore에서 사용자 이름(닉네임) 가져오기
  Future<String?> getUserName(String userId) async {
    try {
      final userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data()?['nickname'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error fetching user name: $e');
      return null;
    }
  }

  /// Firestore에서 사용자 닉네임 변경
  Future<void> updateUserName(
      String userId, String newName, String oldName) async {
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
        transaction.set(
          nicknameRef,
          {'uid': userId, 'created_at': FieldValue.serverTimestamp()},
        );
        transaction.update(userRef, {'nickname': newName});
      });
    } catch (e) {
      // ignore: avoid_print
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

  // ───────────────────────── 재인증 관련 유틸 ─────────────────────────

  /// 현재 사용자에 연결된 providerId 감지
  /// - google.com / apple.com / password / oidc.* 중 하나를 반환
  String? _detectProviderId(User user) {
    final ids = user.providerData.map((p) => p.providerId).toList();
    if (ids.contains('google.com')) return 'google.com';
    if (ids.contains('apple.com')) return 'apple.com';
    if (ids.contains('password')) return 'password';
    final oidc = ids.firstWhere(
          (id) => id.startsWith('oidc.'),
      orElse: () => '',
    );
    if (oidc.isNotEmpty) return oidc;
    return ids.isNotEmpty ? ids.first : null;
  }

  /// providerId별 재인증
  /// - 이메일/비밀번호 사용자는 [email]/[password] 필요
  Future<void> _reauthenticate(User user, {String? email, String? password}) async {
    final providerId = _detectProviderId(user);

    if (providerId == 'google.com') {
      final googleSignIn = GoogleSignIn();
      GoogleSignInAccount? account = await googleSignIn.signInSilently();
      account ??= await googleSignIn.signIn();
      if (account == null) {
        throw FirebaseAuthException(
          code: 'user-cancelled',
          message: 'Google 재인증이 취소되었습니다.',
        );
      }
      final token = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providerId == 'apple.com') {
      final appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final oauth = OAuthProvider('apple.com').credential(
        idToken: appleCred.identityToken,
        accessToken: appleCred.authorizationCode, // 환경에 따라 null일 수 있음
      );
      await user.reauthenticateWithCredential(oauth);
      return;
    }

    if (providerId == 'password') {
      final effectiveEmail = email ?? user.email;
      if (effectiveEmail == null || (password == null || password.isEmpty)) {
        throw FirebaseAuthException(
          code: 'needs-password',
          message: '이메일/비밀번호 재인증을 위해 비밀번호가 필요합니다.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: effectiveEmail,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providerId != null && providerId.startsWith('oidc.')) {
      // 예: oidc.kakao (프로젝트별 OIDC 토큰 획득 후 OAuthProvider('oidc.xxx')로 재인증 구현 필요)
      throw FirebaseAuthException(
        code: 'provider-unsupported',
        message: '현재 로그인 공급자($providerId)의 재인증 처리가 아직 구현되지 않았습니다.',
      );
    }

    throw FirebaseAuthException(
      code: 'provider-unsupported',
      message: '현재 로그인 공급자의 재인증 처리가 아직 구현되지 않았습니다.',
    );
  }

  /// 🔹 사용자 계정 삭제 (Firestore & Authentication)
  /// - 이메일/비밀번호 계정이면 [password]를 넘겨주면 곧바로 재인증까지 처리됨
  Future<void> deleteAccount(BuildContext context, WidgetRef ref, {String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("로그인 정보가 없습니다.")),
          );
        }
        return;
      }

      final userId = user.uid;
      final userRef = _firestore.collection('users').doc(userId);

      // 1) 사용자 데이터(닉네임) 미리 확보
      final userSnapshot = await userRef.get();
      final nickname = userSnapshot.data()?['nickname'];

      // 2) 서브컬렉션 삭제
      await deleteSubCollection(userRef.collection('attendance'));
      await deleteSubCollection(userRef.collection('progress'));
      await deleteSubCollection(userRef.collection('memos'));
      await deleteSubCollection(userRef.collection('bookmarks'));

      // 3) 닉네임 doc 삭제
      if (nickname != null && nickname.toString().isNotEmpty) {
        await _firestore.collection('nicknames').doc(nickname).delete();
      }

      // 4) users/{uid} 문서 삭제
      await userRef.delete();

      // 5) Auth 계정 삭제 (recent-login 필요 시 재인증 → 재삭제)
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await _reauthenticate(user, email: user.email, password: password);
          await user.delete();
        } else {
          rethrow;
        }
      }

      // 6) 상태 초기화
      ref.read(userPhotoUrlProvider.notifier).updatePhotoUrl(null);
      ref.read(userNameProvider.notifier).state = "";

      // 7) 메시지 + 네비게이션 + 재시작
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("탈퇴가 완료되었습니다. 다음에 또 만나요.")),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        RestartWidget.restartApp(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("삭제 중 오류가 발생했습니다: $e")),
        );
      }
    }
  }

  // 학습 시간 저장 메소드
  Future<void> updateLearningTime(int sessionSeconds) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'learningTime': FieldValue.increment(sessionSeconds),
    });
    // 세션 시간만 덮어쓰고 싶다면:
    // await userDoc.update({'learningTime': sessionSeconds});
  }
}

/// 2) 유저 닉네임을 StateNotifier로 관리
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    fetchUserName();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// Firestore에서 닉네임을 한 번 불러오는 메서드
  Future<void> fetchUserName() async {
    final user = _auth.currentUser;
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

    try {
      await _userService.updateUserName(user.uid, newName, oldName);
      state = newName;
      return null; // 성공
    } catch (e) {
      return '닉네임 변경 실패: ${e.toString()}';
    }
  }
}

/// 3) userNameProvider: [UserNameNotifier]의 상태(닉네임)를 노출
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
    return userSnapshot.data()!['email'] as String?;
  }
  return null;
});

/// 사용자의 이름(name)을 가져오는 Provider
final userRealNameProvider = FutureProvider<String?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userSnapshot = await userRef.get();

  if (userSnapshot.exists && userSnapshot.data()!.containsKey('name')) {
    return userSnapshot.data()!['name'] as String?;
  }
  return null;
});

Future<void> updateUserCourse(String userId, String newCourse) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  await userRef.update({'currentCourse': newCourse});
}

final userCourseProvider = FutureProvider<String>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return '미설정';
  final userDoc =
  await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (userDoc.exists) {
    final data = userDoc.data();
    return data?['currentCourse'] as String? ?? '미설정';
  }
  return '미설정';
});

/// StreamProvider: users/{uid} 문서가 바뀌면 실시간 반영
final userLearningStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value({});
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) => snapshot.data() ?? {});
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});
