/// File: auth_controller.dart
/// Purpose: Firebase 및 Google 로그인 기능을 제공하며 사용자 인증 상태를 관리
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Apple 로그인 추가
import '../home/attendance/attendance_service.dart';
import '../home/stage_provider.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, User?>((ref) => AuthController(ref));

class AuthController extends StateNotifier<User?> {
  final Ref ref; // ⬅️ Riverpod의 Ref

  AuthController(this.ref) : super(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google 로그인
  Future<void> signInWithGoogle({
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      await GoogleSignIn().signOut();

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // ✅ Google에서 가져온 displayName을 업데이트
        if (user.displayName == null) {
          await user.updateDisplayName(googleUser.displayName);
        }

        await _handleUserState(user, onNicknameRequired, onHome);
        state = user;
      }
    } catch (e) {
      print('Google 로그인 오류: $e');
    }
  }

  /// 카카오 로그인
  Future<void> signInWithKakao({
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      final token = await kakao.UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공');

      if (token.idToken == null || token.accessToken == null) {
        throw Exception('idToken 또는 accessToken이 null입니다.');
      }

      // ✅ 카카오 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();
      final displayName = kakaoUser.kakaoAccount?.profile?.nickname ?? "사용자";
      print('카카오 사용자 닉네임: $displayName');

      // ✅ Firebase OAuth 인증 정보 생성
      final credential = OAuthProvider('oidc.kakao').credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // ✅ Firebase에서 displayName이 없으면 업데이트
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload(); // 변경된 정보 즉시 반영
        }

        print('Firebase 인증 성공: ${user.uid}');
        await _handleUserState(user, onNicknameRequired, onHome);
      } else {
        throw Exception('Firebase 인증 실패');
      }
    } catch (e) {
      print('카카오 로그인 오류: $e');
    }
  }

  /// 애플 로그인
  Future<void> signInWithApple({
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName, // 이름 요청
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        // ✅ Apple의 fullName이 제공되지 않으면 기존 저장된 이름을 가져옴
        String? fullName = appleCredential.givenName;
        if (fullName == null || fullName.isEmpty) {
          // Firestore 또는 로컬 저장소에서 가져오기 (Firestore 예제)
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data()!.containsKey('fullName')) {
            fullName = userDoc.data()!['fullName'];
          } else {
            fullName = " "; // 기본값
          }
        }

        // ✅ 처음 로그인이라면 Firestore에 이름 저장
        if (appleCredential.givenName != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'fullName': appleCredential.givenName}, SetOptions(merge: true));
        }

        // ✅ Firebase Auth의 Display Name 업데이트
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(fullName);
        }

        await _handleUserState(user, onNicknameRequired, onHome);
        state = user;
      }
    } catch (e) {
      print('Apple 로그인 오류: $e');
    }
  }


  Future<void> _handleUserState(
      User user, Function onNicknameRequired, Function onHome) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userRef.get();

      // 로그인 직후 userIdProvider 업데이트
      ref.read(userIdProvider.notifier).state = user.uid;

      if (!docSnapshot.exists) {
        await userRef.set({
          'name': user.displayName,
          'nicknameSet': false,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'totalXP': 0,
        });
        // 사용자 문서를 생성한 후에 출석 체크 호출
        await markTodayAttendanceAsChecked(user.uid);
        onNicknameRequired();
      } else {
        // 이미 문서가 존재하는 경우
        await markTodayAttendanceAsChecked(user.uid);
        final data = docSnapshot.data()!;
        if (data['nicknameSet'] == true) {
          onHome();
        } else {
          onNicknameRequired();
        }
      }
    } catch (e) {
      print('사용자 상태 확인 오류: $e');
    }
  }

}
