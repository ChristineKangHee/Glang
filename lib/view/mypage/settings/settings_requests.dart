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
        'subject': tr('settings_requests.email_subject'), // 번역된 제목
        'body': tr('settings_requests.email_body'),       // 번역된 본문
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
        title: 'settings.feedback'.tr(), // 기존 문자열 대체
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft, // 텍스트 왼쪽 정렬
              child: Text(
                "settings_requests.title".tr(), // "불편한 점이 있으신가요?"
                style: heading_large(context),
              ),
            ),
            const SizedBox(height: 8), // 간격 추가
            Text(
              "settings_requests.description".tr(), // 설명
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
            function: _sendEmail, // 이메일 전송 기능 연결
            title: 'settings_requests.send_email'.tr(), // 이메일 보내기 버튼
          ),
        ),
      ),
    );
  }
}
