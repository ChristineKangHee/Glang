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
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hgu.zero24@gmail.com',
      queryParameters: {
        'subject': 'requests_email_subject'.tr(),
        'body': 'requests_email_body'.tr(),
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
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
        title: 'feedback_requests'.tr(), // ✅ "문의 및 개선 사항 요청"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('requests_title'.tr(), style: heading_large(context)),
            const SizedBox(height: 8),
            Text(
              'requests_description'.tr(),
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
            function: () => _sendEmail(context),
            title: 'send_email'.tr(),
          ),
        ),
      ),
    );
  }
}
