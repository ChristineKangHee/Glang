import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/community/community_main.dart';
import 'package:readventure/view/course/course_main.dart';
import 'package:readventure/view/home/home.dart';
import 'package:readventure/view/mypage/mypage_main.dart';
import 'viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      // ScreenUtil 사용법
      // .w : width             ex: 170.w
      // .h : height            ex: 170.h
      // .sw : screenwidth      ex: 0.5.sw (screenwidth의 0.5배)
      // .sh : screenheight     ex: 0.6.sh (screenheight의 0.6배)
      // .sp : fontsize         ex: 12.sp

      /*

        ********************** 화면 전체 패딩 넣을 때 18.0 으로 넣을 것 **********************

                             padding: const EdgeInsets.all(18.0),

         ********************** 화면 전체 패딩 넣을 때 18.0 으로 넣을 것 **********************

         */
      designSize: const Size(390, 844), // 기본 디자인 사이즈 설정
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: tr('app_title'),
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
            localizationsDelegates: context.localizationDelegates, // Localization 설정
            supportedLocales: context.supportedLocales, // 지원 언어
            locale: context.locale, // 현재 언어

            //fallbackLocale supportedLocales에 설정한 언어가 없는 경우 설정되는 언어
            // fallbackLocale: Locale('en', 'US'),

            // startLocale을 지정하면 초기 언어가 설정한 언어로 변경됨
            // 만일 이 설정을 하지 않으면 OS 언어를 따라 기본 언어가 설정됨
            // startLocale: Locale('ko', 'KR')

          );
        });
      },
    );
  }
}
