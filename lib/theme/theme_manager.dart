/// File: font.dart
/// Purpose: theme manager
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준
/// Comment: viewmodel의 navigation_controller로 기능 이전.

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:readventure/theme/theme.dart';
//
// // 테마 상태 관리 컨트롤러
// class ThemeController extends GetxController {
//   // 현재 테마 모드
//   Rx<ThemeMode> themeMode = ThemeMode.light.obs;
//
//   // CustomColors 객체 반환
//   CustomColors get customColors {
//     return themeMode.value == ThemeMode.light
//         ? lightThemeGlobal.extension<CustomColors>()!
//         : darkThemeGlobal.extension<CustomColors>()!;
//   }
//
//   // 테마 변경 함수
//   void toggleTheme() {
//     if (themeMode.value == ThemeMode.light) {
//       themeMode.value = ThemeMode.dark;
//     } else {
//       themeMode.value = ThemeMode.light;
//     }
//     update(); // GetX 상태 업데이트
//   }
// }