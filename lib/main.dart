/// File: main.dart
/// Purpose: 앱의 진입점으로 Firebase 초기화, Localization 설정, 테마 및 상태 관리를 초기화하고 앱을 실행
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'viewmodel/app_state_controller.dart';
import 'viewmodel/theme_controller.dart';
import 'viewmodel/navigation_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  //////////////////// 세로 모드 고정 ////////////////////
  WidgetsFlutterBinding.ensureInitialized();

  // Easy Localization 초기화
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
  // KakaoSdk.init(
  //   nativeAppKey: '61dfe0fe1e4375a76b5c97938749086c',
  //   javaScriptAppKey: 'b6a12ba6c8d0fda7a0ecec4569921a1d',
  // );

  //////////////////// 앱 실행 ////////////////////
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')], // 지원 언어
      path: 'lib/localization/l10n', // JSON 파일 경로
      fallbackLocale: const Locale('ko'), // 기본 언어
      child: ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
