// settings_secession.dart
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
    final customColors = ref.watch(customColorsProvider);
    final userService = UserService();

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '탈퇴하기'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$userName님,\n정말 탈퇴하시나요?", style: heading_large(context)),
            SizedBox(height: 8),
            Text(
              "탈퇴 시 모든 데이터가 삭제되며 복구가 불가능합니다",
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
            title: '탈퇴하기',
          ),
        ),
      ),
    );
  }
}

