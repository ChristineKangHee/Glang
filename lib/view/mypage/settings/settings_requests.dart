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

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hgu.zero24@gmail.com',
      queryParameters: {
        'subject': '[문의]앱_사용_중_불편_사항',
        'body': '안녕하세요,\n\n아래_내용을_작성하여_문의해_주세요:\n\n-발생한_문제:\n-기기_및_OS_정보:\n-추가_의견:\n\n감사합니다.',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("이메일 클라이언트를 열 수 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '문의 및 개선 사항 요청'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "불편한 점이 있으신가요?",
                style: heading_large(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "이용 중 불편한 점이나 문의사항을 알려주세요.\n평일 (월~금) 10:00~18:00, 주말 및 공휴일 휴무",
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 하단 여백 추가
        child: SizedBox(
          width: double.infinity, // 버튼이 가득 차도록 설정
          child: ButtonPrimary_noPadding(
            function: _sendEmail, // 이메일 전송 기능 연결
            title: '이메일 보내기',
          ),
        ),
      ),
    );
  }
}
