import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/community/community_main.dart';
import 'package:readventure/view/course/course_main.dart';
import 'package:readventure/view/home/home.dart';
import 'package:readventure/view/mypage/mypage_main.dart';
import 'viewmodel/theme_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(390, 844), // 기본 디자인 사이즈 설정
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: 'Readventure',
            theme: themeController.lightTheme, // 라이트 테마
            darkTheme: themeController.darkTheme, // 다크 테마
            themeMode: themeController.themeMode, // 테마 모드
            initialRoute: '/', // 초기 경로 설정 (스플래시 페이지로 변경 예정)
            getPages: [
              GetPage(
                name: '/',
                page: () => const MyHomePage(),
              ),
              GetPage(
                name: '/course',
                page: () => const CourseMain(),
              ),
              GetPage(
                name: '/community',
                page: () => const CommunityMain(),
              ),
              GetPage(
                name: '/mypage',
                page: () => const MyPageMain(),
              ),
            ],
          );
        });
      },
    );
  }
}
