/// File: settings_theme.dart
/// Purpose: 앱 설정에서 라이트/다크 테마 전환 (L10N/UX 보강)
/// Author: 박민준
/// Last Modified: 2025-08-26 by ChatGPT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodel/theme_controller.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';

class SettingsTheme extends ConsumerWidget {
  const SettingsTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeProvider.notifier);
    final isLightTheme = ref.watch(themeProvider); // true: Light, false: Dark
    final customColors = ref.watch(customColorsProvider);

    Future<void> changeTheme(bool toLight) async {
      if (isLightTheme == toLight) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('theme_already_selected'.tr())),
        );
        return;
      }
      themeController.toggleTheme();
      final name = toLight ? 'light_theme'.tr() : 'dark_theme'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('theme_changed_to'.tr(args: [name]))),
      );
    }

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'theme_settings'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOptionTile(
              icon: Icons.light_mode,
              title: 'light_theme'.tr(),
              subtitle: 'light_theme_sub'.tr(),
              selected: isLightTheme,
              onTap: () => changeTheme(true),
              customColors: customColors,
            ),
            Divider(color: customColors.neutral80),
            _ThemeOptionTile(
              icon: Icons.dark_mode,
              title: 'dark_theme'.tr(),
              subtitle: 'dark_theme_sub'.tr(),
              selected: !isLightTheme,
              onTap: () => changeTheme(false),
              customColors: customColors,
            ),
            Divider(color: customColors.neutral80),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final CustomColors customColors;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 75,
        width: double.infinity,
        child: Row(
          children: [
            Icon(icon, size: 22, color: customColors.neutral30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: body_small_semi(context)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: body_xsmall(context).copyWith(color: customColors.neutral60),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, color: customColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
