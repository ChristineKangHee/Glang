/// File: app.dart
/// Purpose: 앱의 전체 구조를 설정하고 테마, 다국어, 네비게이션 경로 및 화면 크기 조정을 관리
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2025-01-09 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/community/Board/CM_1depth_firebase.dart';
import 'package:readventure/view/course/course_main.dart';
import 'package:readventure/view/feature/after_read/AR_main.dart';
import 'package:readventure/view/feature/before_read/BR_main.dart';
import 'package:readventure/view/feature/reading/GA_02/RD_main.dart';
import 'package:readventure/view/home/attendance/attendance_service.dart';
import 'package:readventure/view/home/home.dart';
import 'package:readventure/view/home/notification/notification_page.dart';
import 'package:readventure/view/home/stage_provider.dart';
import 'package:readventure/view/login/auth_controller.dart';
import 'package:readventure/view/login/login_main.dart';
import 'package:readventure/view/login/nickname_input.dart';
import 'package:readventure/view/login/tutorial.dart';
import 'package:readventure/view/mypage/edit_nick_input.dart';
import 'package:readventure/view/mypage/info/info_badge.dart';
import 'package:readventure/view/mypage/edit_profile.dart';
import 'package:readventure/view/mypage/info/info_history.dart';
import 'package:readventure/view/mypage/info/info_interpretation_bookmark.dart';
import 'package:readventure/view/mypage/info/info_mycommunitypost.dart';
import 'package:readventure/view/mypage/info/info_statistics.dart';
import 'package:readventure/view/mypage/info/memo_list_page.dart';
import 'package:readventure/view/mypage/mypage_main.dart';
import 'package:readventure/view/mypage/info/info_saved.dart';
import 'package:readventure/view/mypage/settings/settings_language.dart';
import 'package:readventure/view/mypage/settings/settings_FAQ.dart';
import 'package:readventure/view/mypage/settings/settings_politics.dart';
import 'package:readventure/view/mypage/settings/settings_announcement.dart';
import 'package:readventure/view/mypage/settings/settings_reportlistpage.dart';
import 'package:readventure/view/mypage/settings/settings_requests.dart';
import 'package:readventure/view/mypage/settings/settings_secession.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/mypage/settings/settings_page.dart';
import 'package:readventure/view/mypage/settings/settings_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyApp extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isLightTheme = ref.watch(themeProvider); // 테마 상태를 읽음
    final themeController = ref.read(themeProvider.notifier); // 테마 컨트롤러
    final user = ref.watch(appStateProvider); // 현재 로그인한 사용자 정보
    ref.watch(authControllerProvider);


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
          debugShowCheckedModeBanner: false, // 🔥 이 줄 추가
          title: tr('app_title'), // Localization을 통해 앱 제목 가져오기
          theme: isLightTheme ? themeController.lightTheme : themeController.darkTheme, // 라이트/다크 테마
          darkTheme: themeController.darkTheme, // 다크 테마
          themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark, // 테마 모드
          // initialRoute: '/login', // 초기 경로 설정 (스플래시 페이지로 변경 예정)
          home: const AuthWrapper(), // 초기 화면을 AuthWrapper로 지정
          routes: {
            // '/': (context) => const MyHomePage(),
            '/tutorial': (context) => TutorialScreen(),
            // '/armain': (context) => const ArMain(),
            '/brmain': (context) => const BrMain(),
            '/rdmain': (context) => RdMain(),
            '/login': (context) => const LoginPage(),
            '/nickname': (context) => const NicknameInput(),
            '/notification': (context) => const NotificationPage(),
            '/course': (context) => CourseMain(),
            '/community': (context) => CommunityMainPage(),
            '/mypage': (context) => const MyPageMain(),
            '/mypage/settings' : (context) => const SettingsPage(),
            '/mypage/settings/announcement' : (context) => const SettingsAnnouncement(),
            '/mypage/settings/FAQ' : (context) => const SettingsFAQ(),
            '/mypage/settings/theme' : (context) => const SettingsTheme(),
            '/mypage/settings/language' : (context) => const SettingsLanguage(),
            '/mypage/settings/politics' : (context) => const SettingsPolitics(),
            '/mypage/settings/requests' : (context) => const SettingsRequests(),
            '/mypage/settings/secession' : (context) => const SettingsSecession(),
            '/mypage/edit_profile' : (context) => const EditProfile(),
            '/mypage/edit_nick_input' : (context) => const EditNickInput(),
            '/mypage/info/statistics' : (context) => const InfoStatistics(),
            '/mypage/info/badge' : (context) => const InfoBadge(),
            '/mypage/info/memo' : (context) => const MemoListPage(),
            '/mypage/info/interpretation' : (context) => const BookmarksPage(),
            '/mypage/info/history' : (context) => const InfoHistory(),
            '/mypage/info/mycommunitypost' : (context) => MyPostsPage(),
            '/mypage/settings/reports': (context) => ReportListPage(),
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



/// 로그인 상태 및 닉네임 설정 여부를 확인하는 위젯 (ConsumerWidget로 변경)
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;

          // 빌드가 완료된 후에 provider 상태 업데이트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(userIdProvider.notifier).state = user.uid;
          });

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userDocSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${userDocSnapshot.error}')),
                );
              }
              if (userDocSnapshot.hasData) {
                final data = userDocSnapshot.data?.data();

                // 출석체크 함수 호출 (단, 여러 번 호출되지 않도록 주의)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  markTodayAttendanceAsChecked(user.uid);
                });

                if (data is Map<String, dynamic> && data['nicknameSet'] == true) {
                  return const MyHomePage();
                } else {
                  return const NicknameInput();
                }
              }
              return const NicknameInput();
            },
          );
        }


        // 로그인되어 있지 않은 경우 로그인 화면 표시
        return const LoginPage();
      },
    );
  }
}
