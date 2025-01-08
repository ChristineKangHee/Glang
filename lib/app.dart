/// File: app.dart
/// Purpose: 앱의 전체 구조를 설정하고 테마, 다국어, 네비게이션 경로 및 화면 크기 조정을 관리
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/community/community_main.dart';
import 'package:readventure/view/course/course_main.dart';
import 'package:readventure/view/home/example.dart';
import 'package:readventure/view/home/home.dart';
import 'package:readventure/view/home/notification/notification_page.dart';
import 'package:readventure/view/login/nickname_input.dart';
import 'package:readventure/view/mypage/mypage_main.dart';
import 'package:readventure/view/mypage/settings/settings_language.dart';
import 'package:readventure/view/mypage/settings/settings_notification.dart';
import 'package:readventure/view/mypage/settings/settings_profile.dart';
import 'viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/mypage/settings/settings_page.dart';
import 'package:readventure/view/mypage/settings/settings_theme.dart';

class MyApp extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(themeProvider); // 테마 상태를 읽음
    final themeController = ref.read(themeProvider.notifier); // 테마 컨트롤러

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
        return MaterialApp(
          title: tr('app_title'), // Localization을 통해 앱 제목 가져오기
          theme: isLightTheme ? themeController.lightTheme : themeController.darkTheme, // 라이트/다크 테마
          darkTheme: themeController.darkTheme, // 다크 테마
          themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark, // 테마 모드
          initialRoute: '/', // 초기 경로 설정 (스플래시 페이지로 변경 예정)
          routes: {
            '/': (context) => const MyHomePage(),
            '/notification': (context) => const NotificationPage(),
            '/course': (context) => CourseMain(),
            '/community': (context) => const CommunityMain(),
            '/mypage': (context) => const MyPageMain(),
            '/mypage/settings' : (context) => const SettingsPage(),
            '/mypage/settings/profile' : (context) => const NicknameInput(),
            '/mypage/settings/notification' : (context) => const SettingsNotification(),
            '/mypage/settings/theme' : (context) => const SettingsTheme(),
            '/mypage/settings/language' : (context) => const SettingsLanguage(),
          },
          localizationsDelegates: context.localizationDelegates, // Localization 설정
          supportedLocales: context.supportedLocales, // 지원 언어
          locale: context.locale, // 현재 언어

          // fallbackLocale supportedLocales에 설정한 언어가 없는 경우 설정되는 언어
          // fallbackLocale: Locale('en', 'US'),

          // startLocale을 지정하면 초기 언어가 설정한 언어로 변경됨
          // 만일 이 설정을 하지 않으면 OS 언어를 따라 기본 언어가 설정됨
          // startLocale: Locale('ko', 'KR')

        );
      },
    );
  }
}
