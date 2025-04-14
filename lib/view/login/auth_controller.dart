/// File: auth_controller.dart
/// Purpose: Firebase 및 Google 로그인 기능을 제공하며 사용자 인증 상태를 관리
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // AlertDialog를 사용하기 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Apple 로그인 추가
import '../home/attendance/attendance_service.dart';
import '../home/stage_provider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

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
        // Firestore에서 사용자 문서 가져오기
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()?['photoURL'] != null) {
          // 이미 커스텀 프로필 사진이 저장되어 있다면 이를 사용
          final customPhotoUrl = userDoc.data()!['photoURL'];
          if (user.photoURL != customPhotoUrl) {
            await user.updatePhotoURL(customPhotoUrl);
          }
        } else {
          // 저장된 커스텀 사진이 없다면, 소셜 로그인 시 받은 사진을 사용
          if (googleUser.photoUrl != null) {
            await user.updatePhotoURL(googleUser.photoUrl);
          }
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
      final photoUrl = kakaoUser.kakaoAccount?.profile?.profileImageUrl;
      print('카카오 사용자 닉네임: $displayName');

      final credential = OAuthProvider('oidc.kakao').credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Firestore에서 사용자 문서 가져오기
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data()?['photoURL'] != null) {
          // 이미 저장된 custom 프로필 사진이 있다면 이를 사용
          final customPhotoUrl = userDoc.data()!['photoURL'];
          if (user.photoURL != customPhotoUrl) {
            await user.updatePhotoURL(customPhotoUrl);
          }
        } else {
          // 저장된 커스텀 사진이 없다면, Kakao에서 받아온 사진을 사용
          if (photoUrl != null) {
            await user.updatePhotoURL(photoUrl);
          }
        }

        await _handleUserState(user, onNicknameRequired, onHome);
      }
      else {
        throw Exception('Firebase 인증 실패');
      }
    } catch (e) {
      _showErrorDialog(context, '카카오 로그인 오류', e.toString());
    }
  }

  String _generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple({
    required BuildContext context,
    required Function onNicknameRequired,
    required Function onHome,
  }) async {
    try {
      final provider = OAuthProvider("apple.com")
        ..addScope('email')
        ..addScope('name')
        ..setCustomParameters({
          'client_id': 'com.zero.glang2025.web', // ✅ 반드시 Service ID와 일치
          'redirect_uri': 'https://glang-98622.firebaseapp.com/__/auth/handler', // ✅ Firebase의 redirect URI
          'response_type': 'code id_token',
        });

      final userCredential = await FirebaseAuth.instance.signInWithProvider(provider);
      final user = userCredential.user;

      if (user != null) {
        await _handleUserState(user, onNicknameRequired, onHome);
        state = user;
      }
    } catch (e) {
      print('❌ Firebase Apple 로그인 실패: $e');
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
          'photoURL': user.photoURL, // <-- 신규 사용자 생성 시 프로필 사진 URL 저장
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
