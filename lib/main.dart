import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'app.dart';
import 'package:get/get.dart';
import 'viewmodel/theme_controller.dart';
import 'viewmodel/navigation_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  //////////////////// 세로 모드 고정 ////////////////////
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //////////////////// Firebase 연결 ////////////////////
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  // 카카오 로그인 (이전 코드)
  // KakaoSdk.init(
  //   nativeAppKey: '61dfe0fe1e4375a76b5c97938749086c',
  //   javaScriptAppKey: 'b6a12ba6c8d0fda7a0ecec4569921a1d',
  // );

  //////////////////// GetX 컨트롤러 초기화 ////////////////////
  Get.put(ThemeController());
  Get.put(NavigationController());
  Get.put(AppStateController());

  //////////////////// 앱 실행 ////////////////////
  runApp(const MyApp());
}
