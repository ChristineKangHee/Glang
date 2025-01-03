/// File: settings_theme.dart
/// Purpose: 앱 설정에서 라이트 및 다크 테마를 전환할 수 있는 UI 제공
/// Author: 박민준
/// Created: 2025-01-03
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsTheme extends ConsumerWidget {
  const SettingsTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeProvider.notifier); // 테마 컨트롤러
    final isLightTheme = ref.watch(themeProvider); // 현재 테마 상태

    return Scaffold(
      appBar:
      AppBar(
        title: const Text('app_title').tr(),
        actions: [
          IconButton(
            icon: Icon(isLightTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeController.toggleTheme(); // 테마 변경
            },
          ),
        ],
      ),
    );
  }
}

