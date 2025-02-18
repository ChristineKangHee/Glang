/// File: auth_controller.dart
/// Purpose: Firebase 및 Google 로그인 기능을 제공하며 사용자 인증 상태를 관리
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter/material.dart'; // AlertDialog를 사용하기 위해 추가
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
  final Ref ref;
  AuthController(this.ref) : super(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google 로그인
  Future<void> signInWithGoogle({
    required BuildContext context,
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
        if (user.displayName == null) {
          await user.updateDisplayName(googleUser.displayName);
        }
        await _handleUserState(user, onNicknameRequired, onHome);
        state = user;
      }
    } catch (e) {
      _showErrorDialog(context, 'Google 로그인 오류', e.toString());
    }
  }

  /// 카카오 로그인
  Future<void> signInWithKakao({
    required BuildContext context,
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      final isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();
      kakao.OAuthToken token;

      if (isKakaoTalkInstalled) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('카카오톡 앱 로그인 실패, 웹으로 재시도: $error');
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      if (token.idToken == null || token.accessToken == null) {
        throw Exception('idToken 또는 accessToken이 null입니다.');
      }

      final kakaoUser = await kakao.UserApi.instance.me();
      final displayName = kakaoUser.kakaoAccount?.profile?.nickname ?? "사용자";
      print('카카오 사용자 닉네임: $displayName');

      final credential = OAuthProvider('oidc.kakao').credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }
        print('Firebase 인증 성공: ${user.uid}');
        await _handleUserState(user, onNicknameRequired, onHome);
      } else {
        throw Exception('Firebase 인증 실패');
      }
    } catch (e) {
      _showErrorDialog(context, '카카오 로그인 오류', e.toString());
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple({
    required BuildContext context,
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      if (user != null) {
        await _handleUserState(user, onNicknameRequired, onHome);
        state = user;
      }
    } catch (e) {
      _showErrorDialog(context, 'Apple 로그인 오류', e.toString());
    }
  }

  Future<void> _handleUserState(
      User user, Function onNicknameRequired, Function onHome) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userRef.get();
      ref.read(userIdProvider.notifier).state = user.uid;

      if (!docSnapshot.exists) {
        await userRef.set({
          'name': user.displayName,
          'nicknameSet': false,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'totalXP': 0,
          'currentCourse': '코스1', // 기본 코스 설정
          'learningTime': 0,
          'completedMissionCount': 0,
        });
        await markTodayAttendanceAsChecked(user.uid);
        onNicknameRequired();
      } else {
        final data = docSnapshot.data()!;
        if (!data.containsKey('currentCourse')) {
          await userRef.update({'currentCourse': '코스1'});
        }
        await markTodayAttendanceAsChecked(user.uid);
        if (data['nicknameSet'] == true) {
          onHome();
        } else {
          onNicknameRequired();
        }
      }
    } catch (e) {
      // _handleUserState 내부 에러도 AlertDialog로 보여주기
      // 이 경우 context가 없으므로, 간단하게 print와 별도 처리를 할 수도 있음.
      print('사용자 상태 확인 오류: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("확인"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
