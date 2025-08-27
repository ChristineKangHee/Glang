/// File: settings_language.dart
/// Purpose: 언어 설정 화면 UI 개선 (L10N/UX 보강)
/// Author: 강희
/// Last Modified: 2025-08-26 by ChatGPT

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

    Future<void> changeLocale(String code, String displayName) async {
      if (currentLocale.languageCode == code) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('language_already_selected'.tr())),
        );
        return;
      }
      await context.setLocale(Locale(code));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('language_changed_to'.tr(args: [displayName]))),
      );
    }

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'language_settings'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context: context,
              title: 'language_korean'.tr(),        // ex) 한국어 / Korean (로캘에 따라)
              subtitle: 'language_korean_alt'.tr(), // 보조 표기
              selected: currentLocale.languageCode == 'ko',
              onTap: () => changeLocale('ko', 'language_korean'.tr()),
              customColors: customColors,
            ),
            Divider(color: customColors.neutral80),
            _buildLanguageOption(
              context: context,
              title: 'language_english'.tr(),        // ex) 영어 / English
              subtitle: 'language_english_alt'.tr(), // 보조 표기
              selected: currentLocale.languageCode == 'en',
              onTap: () => changeLocale('en', 'language_english'.tr()),
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
                  Text(title, style: body_small_semi(context)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: body_xsmall(context).copyWith(color: customColors.neutral60),
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
