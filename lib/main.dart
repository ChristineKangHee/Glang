import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'app.dart';
import 'package:get/get.dart';
import 'viewmodel/theme_controller.dart';
import 'viewmodel/navigation_controller.dart';
import 'viewmodel/app_state_controller.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  //////////////////// 세로 모드 고정 ////////////////////
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //////////////////// Firebase 연결 ////////////////////
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Readventure',
        theme: themeController.lightTheme, // 라이트 테마
        darkTheme: themeController.darkTheme, // 다크 테마
        themeMode: themeController.themeMode, // 테마 모드
        home: MyApp(), // 앱의 메인 진입점
      );
    });
  }
}
