/// File: settings_requests.dart
/// Purpose: 설정 화면에서 '문의 및 개선 사항 요청'을 위한 위젯 (L10N 보강)
/// Author: 강희
/// Last Modified: 2025-08-26 by ChatGPT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

class SettingsRequests extends ConsumerWidget {
  const SettingsRequests({super.key});

  Future<void> _sendEmail(BuildContext context) async {
    final subject = tr('settings_requests.email_subject');
    final body = tr('settings_requests.email_body');

    // mailto URI 구성 (줄바꿈 등 안전하게 인코딩)
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hgu.zero24@gmail.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    // 외부 앱으로 여는 모드가 더 안정적
    final canOpen = await canLaunchUrl(emailUri);
    if (canOpen) {
      final ok = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('email_client_unavailable'.tr())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('email_client_unavailable'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'settings.feedback'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "settings_requests.title".tr(),
                style: heading_large(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "settings_requests.description".tr(),
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ButtonPrimary_noPadding(
            // ✅ context를 함께 넘겨야 함
            function: () => _sendEmail(context),
            title: 'settings_requests.send_email'.tr(),
          ),
        ),
      ),
    );
  }
}
