// settings_secession.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

// 설정 - 회원 탈퇴 화면 위젯
class SettingsSecession extends ConsumerWidget {
  const SettingsSecession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 이름 상태 구독
    final userName = ref.watch(userNameProvider);
    // 커스텀 색상 테마 상태 구독
    final customColors = ref.watch(customColorsProvider);
    // 사용자 서비스 인스턴스 생성
    final userService = UserService();

    return Scaffold(
      // 커스텀 앱 바 적용 (2단계, 4종류)
      appBar: CustomAppBar_2depth_4(
        title: '탈퇴하기'.tr(), // 다국어 처리된 제목
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사용자 이름을 포함한 탈퇴 확인 메시지
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$userName님,\n정말 탈퇴하시나요?",
                style: heading_large(context),
              ),
            ),
            SizedBox(height: 8,), // 간격 추가
            // 탈퇴 시 데이터 삭제 경고 문구
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "탈퇴 시 모든 데이터가 삭제되며 복구가 불가능합니다",
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
            function: () => userService.deleteAccount(context, ref), // 계정 삭제 기능 실행
            title: '탈퇴하기',
          ),
        ),
      ),
    );
  }
}
