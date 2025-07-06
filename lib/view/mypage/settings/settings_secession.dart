/// File: settings_secession.dart
/// Purpose: 설정 - 회원 탈퇴 화면 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

class SettingsSecession extends ConsumerStatefulWidget {
  const SettingsSecession({Key? key}) : super(key: key);

  @override
  _SettingsSecessionState createState() => _SettingsSecessionState();
}

class _SettingsSecessionState extends ConsumerState<SettingsSecession> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    // 커스텀 색상 테마 상태 구독
    final customColors = ref.watch(customColorsProvider);
    // 사용자 서비스 인스턴스 생성
    final userService = UserService();

    return Scaffold(
    // 커스텀 앱 바 적용 (2단계, 4종류)
      appBar: CustomAppBar_2depth_4(
        title: 'settings_secession.title'.tr(), // '탈퇴하기'
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 이름을 포함한 탈퇴 확인 메시지
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$userName,\n${'settings_secession.confirm_message'.tr()}",
                style: heading_large(context),
              ),
            ),
            SizedBox(height: 8,), // 간격 추가
            // 탈퇴 시 데이터 삭제 경고 문구
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'settings_secession.warning'.tr(),
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            ),
          ],
        ),
      ),
      // 하단 탈퇴 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ButtonPrimary_noPadding(
            // _isDeleting가 true이면 버튼 비활성화 (혹은 함수 내에서 아무 작업도 하지 않도록)
            function: _isDeleting
                ? () {}
                : () async {
              setState(() {
                _isDeleting = true;
              });
              await userService.deleteAccount(context, ref);
              // 탈퇴 후에는 Navigator로 이동되지만,
              // 혹시 모를 에러나 후처리를 위해 _isDeleting 상태 복구
              if (mounted) {
                setState(() {
                  _isDeleting = false;
                });
              }
            },
            title: 'settings_secession.title'.tr(),
          ),
        ),
      ),
    );
  }
}

