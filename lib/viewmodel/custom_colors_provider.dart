import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:readventure/viewmodel/theme_controller.dart';
import '../theme/theme.dart';

final customColorsProvider = Provider<CustomColors>((ref) {
  final isLightTheme = ref.watch(themeProvider); // true: Light, false: Dark
  final theme = isLightTheme ? lightThemeGlobal : darkThemeGlobal;

  // extensions에서 CustomColors 가져오기
  final customColors = theme.extensions[CustomColors] as CustomColors?;
  if (customColors == null) {
    throw Exception('CustomColors not found in ThemeData extensions.');
  }
  return customColors;
});
