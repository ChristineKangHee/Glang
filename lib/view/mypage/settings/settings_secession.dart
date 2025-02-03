import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';
import '../../home/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsSecession extends ConsumerWidget {
  const SettingsSecession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider); // 사용자 이름 상태 구독
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? userId = _auth.currentUser?.uid;
    final customColors = ref.watch(customColorsProvider);

    if (userId != null) {
      ref.read(userNameProvider.notifier).fetchUserName(userId);
    }

    Future<void> _deleteAccount() async {
      try {
        // Delete the user's account
        await _auth.currentUser?.delete();

        // Show a confirmation message or navigate after account deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("계정이 삭제되었습니다.")),
        );

        // Navigate the user to the login screen after deletion
        Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login screen
      } catch (e) {
        // Handle any errors that occur during account deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("삭제 중 오류가 발생했습니다: $e")),
        );
      }
    }

    return Scaffold(
      appBar:
      CustomAppBar_2depth_4(
        title: '탈퇴하기'.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft, // Aligning the text to the left
              child: Text("$userName님,\n정말 탈퇴하시나요?", style: heading_large(context)),
            ),
            SizedBox(height: 8,),
            Align(
              alignment: Alignment.centerLeft, // Aligning the text to the left
              child: Text(
                "탈퇴 시 모든 데이터가 삭제되며 복구가 불가능합니다",
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 하단 여백 추가
        child: SizedBox(
          width: double.infinity, // 버튼이 가득 차도록 설정
          child: ButtonPrimary_noPadding(
            function: _deleteAccount, // Call the delete function here
            title: '탈퇴하기',
          ),
        ),
      ),
    );
  }
}
