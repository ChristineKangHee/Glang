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

import '../home/attendance/attendance_service.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, User?>((ref) => AuthController());

class AuthController extends StateNotifier<User?> {
  AuthController() : super(null);

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
      print('idToken: ${token.idToken}');
      print('accessToken: ${token.accessToken}');

      if (token.idToken == null || token.accessToken == null) {
        throw Exception('idToken 또는 accessToken이 null입니다.');
      }

      final credential = OAuthProvider('oidc.kakao').credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('Firebase 인증 성공: ${user.uid}');
        await _handleUserState(user, onNicknameRequired, onHome);
      } else {
        throw Exception('Firebase 인증 실패');
      }
    } catch (e) {
      print('카카오 로그인 오류: $e');
    }
  }


  Future<void> _handleUserState(User user, Function onNicknameRequired, Function onHome) async {
    try {
      // **여기서 출석 체크 호출**
      await markTodayAttendanceAsChecked(user.uid);

      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();


      if (!docSnapshot.exists) {
        await userDoc.set({
          'nicknameSet': false,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        onNicknameRequired();
      } else {
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
