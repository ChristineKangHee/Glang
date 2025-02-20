/// File: settings_requests.dart
/// Purpose: 설정 화면에서 '문의 및 개선 사항 요청'을 위한 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

/// 설정 화면에서 '문의 및 개선 사항 요청'을 위한 위젯
/// Riverpod의 ConsumerWidget을 사용하여 상태 관리를 수행함
class SettingsRequests extends ConsumerWidget {
  const SettingsRequests({super.key});

  /// 이메일을 보내는 기능을 수행하는 메서드
  void _sendEmail() async {
    // 이메일 URI 설정
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hgu.zero24@gmail.com', // 수신 이메일 주소
      queryParameters: {
        'subject': '[문의]앱_사용_중_불편_사항', // 기본 제목 설정
        'body': '안녕하세요,\n\n아래_내용을_작성하여_문의해_주세요:\n\n'
            '-발생한_문제:\n'
            '-기기_및_OS_정보:\n'
            '-추가_의견:\n\n'
            '감사합니다.', // 기본 본문 내용 설정
      },
    );

    // 이메일 앱을 열 수 있는지 확인 후 실행
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("이메일 클라이언트를 열 수 없습니다."); // 오류 발생 시 디버그 출력
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 커스텀 컬러 테마 가져오기
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '문의 및 개선 사항 요청'.tr(), // 다국어 지원
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 바디 패딩 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Align(
              alignment: Alignment.centerLeft, // 텍스트 왼쪽 정렬
              child: Text(
                "불편한 점이 있으신가요?", // 제목 텍스트
                style: heading_large(context),
              ),
            ),
            const SizedBox(height: 8), // 간격 추가
            Text(
              "이용 중 불편한 점이나 문의사항을 알려주세요.\n"
                  "평일 (월~금) 10:00~18:00, 주말 및 공휴일 휴무", // 설명 텍스트
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 하단 여백 추가
        child: SizedBox(
          width: double.infinity, // 버튼이 화면 너비를 가득 채우도록 설정
          child: ButtonPrimary_noPadding(
            function: _sendEmail, // 이메일 전송 기능 연결
            title: '이메일 보내기', // 버튼 텍스트
          ),
        ),
      ),
    );
  }
}
