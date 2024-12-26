import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/community/community_main.dart';
import 'package:readventure/view/course/course_main.dart';
import 'package:readventure/view/home/home.dart';
import 'package:readventure/view/mypage/mypage_main.dart';
import 'viewmodel/theme_controller.dart';
import 'localization/app_localizations.dart';
import 'localization/app_localizations_delegate.dart';

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
            supportedLocales: const [
              Locale('en'), // 영어
              Locale('ko'), // 한국어
            ],
            /*
            Localization 사용법

            @override
              Widget build(BuildContext context) {
              밑에
              final localizations = AppLocalizations.of(context);
              선언 (locale 사용 위함)

              실제 사용 예시
              Text(localizations!.translate('app_title')), // 앱 제목

              localization/l10n/ 의 en.json, ko.json 에 text 추가 후 사용.

            */
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // 사용자 장치 언어 설정에 따라 Locale 결정
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
          );
        });
      },
    );
  }
}
