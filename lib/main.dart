/// File: main.dart
/// Purpose: 앱의 진입점으로 Firebase 초기화, Localization 설정, 테마 및 상태 관리를 초기화하고 앱을 실행
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readventure/viewmodel/notification_controller.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  //////////////////// 세로 모드 고정 ////////////////////
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // env 파일 불러오기
  String envPath;
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully!");
  } catch (e) {
    print("⚠️ Failed to load .env file: $e");
    // 기본 설정으로 동작하도록 설정 가능
  }

  // local notification
  await requestNotificationPermission();
  await initializeNotifications();

  // Easy Localization 초기화
  await EasyLocalization.ensureInitialized();

  //////////////////// Firebase 연결 ////////////////////
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 Firebase initialized successfully!"); // 정상 연결 검증
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  // 카카오 로그인 (이전 코드)
  KakaoSdk.init(
    nativeAppKey: '5fc90edd56a963389d62ce93012c0c80',
    javaScriptAppKey: '0e94fd00949264ca099b7626f5138e5a',
  );

  //////////////////// 앱 실행 ////////////////////
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')], // 지원 언어
      path: 'lib/localization/l10n', // JSON 파일 경로
      fallbackLocale: const Locale('ko'), // 기본 언어
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
