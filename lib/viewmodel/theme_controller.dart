// modelview/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme.dart';

class ThemeController extends GetxController {
  RxBool isLightTheme = true.obs;

  ThemeData get lightTheme => lightThemeGlobal;
  ThemeData get darkTheme => darkThemeGlobal;

  ThemeMode get themeMode => isLightTheme.value ? ThemeMode.light : ThemeMode.dark;

  void toggleTheme() {
    isLightTheme.value = !isLightTheme.value;
  }
}
