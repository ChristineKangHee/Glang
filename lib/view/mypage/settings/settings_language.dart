/// File: settings_language.dart
/// Purpose: 언어 설정 화면 UI 개선
/// Author: 강희
/// Last Modified: 2025-06-28 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class SettingsLanguage extends ConsumerWidget {
  const SettingsLanguage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale currentLocale = context.locale;
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '언어 설정'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context: context,
              title: '한국어',
              subtitle: 'Korean',
              selected: currentLocale.languageCode == 'ko',
              onTap: () => context.setLocale(const Locale('ko')),
              customColors: customColors,
            ),
            Divider(color: customColors.neutral80),
            _buildLanguageOption(
              context: context,
              title: 'English',
              subtitle: 'English',
              selected: currentLocale.languageCode == 'en',
              onTap: () => context.setLocale(const Locale('en')),
              customColors: customColors,
            ),
            Divider(color: customColors.neutral80),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required CustomColors customColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16), // ✅ height 대신 padding
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: body_small_semi(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: body_xsmall(context).copyWith(
                      color: customColors.neutral60,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check, color: customColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
