/// File: settings_secession.dart
/// Purpose: 설정 - 회원 탈퇴 화면 위젯 (L10N/확인 다이얼로그/로딩 상태)
/// Author: 강희
/// Last Modified: 2025-08-26 by ChatGPT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';
import '../../components/alarm_dialog.dart'; // ✅ 확인 다이얼로그 재사용

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

    final nameToShow = userName ?? '';

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'account_delete'.tr(), // ✅ "탈퇴하기"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'delete_greeting'.tr(args: [nameToShow]), // ✅ "{}님,\n정말 탈퇴하시나요?"
                style: heading_large(context),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'delete_warning'.tr(), // ✅ "탈퇴 시 모든 데이터가 삭제되며 복구가 불가능합니다"
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ButtonPrimary_noPadding(
            function: _isDeleting
                ? () {}
                : () async {
              // ✅ 삭제 전 확인 다이얼로그
              showResultSaveDialog(
                context,
                customColors,
                'delete_confirm_prompt'.tr(), // "정말 탈퇴하시겠습니까?"
                'cancel'.tr(),
                'yes'.tr(),
                    (ctx) async {
                  if (mounted) {
                    setState(() => _isDeleting = true);
                  }
                  try {
                    await userService.deleteAccount(context, ref);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('delete_failed'.tr())),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isDeleting = false);
                    }
                  }
                },
              );
            },
            title: _isDeleting ? 'deleting'.tr() : 'account_delete'.tr(),
          ),
        ),
      ),
    );
  }
}
