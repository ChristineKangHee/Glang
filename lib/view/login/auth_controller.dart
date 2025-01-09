/// File: auth_controller.dart
/// Purpose: Firebase 및 Google 로그인 기능을 제공하며 사용자 인증 상태를 관리
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, User?>((ref) => AuthController());

class AuthController extends StateNotifier<User?> {
  AuthController() : super(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle({required Function onNicknameRequired, required Function onHome}) async {
    try {
      await GoogleSignIn().signOut(); // 캐시된 계정 로그아웃

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

  Future<void> _handleUserState(User user, Function onNicknameRequired, Function onHome) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // 최초 로그인 시 Firestore에 사용자 문서 생성
        await userDoc.set({
          'nicknameSet': false,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        onNicknameRequired(); // 별명 설정 화면으로 이동
      } else {
        // 기존 사용자인 경우 nicknameSet 상태 확인
        final data = docSnapshot.data()!;
        if (data['nicknameSet'] == true) {
          onHome(); // 홈 화면으로 이동
        } else {
          onNicknameRequired(); // 별명 설정 화면으로 이동
        }
      }
    } catch (e) {
      print('사용자 상태 확인 오류: $e');
    }
  }
}