/// File: edit_nick.dart
/// Purpose: 사용자의 별명를 수정할 수 있다. (L10N 적용)
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-08-26 by ChatGPT (L10N)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../components/custom_textfield.dart';
import '../../viewmodel/user_service.dart' as viewmodel;
import 'edit_profile.dart';
import 'package:easy_localization/easy_localization.dart';

class EditNickInput extends ConsumerStatefulWidget {
  const EditNickInput({super.key});

  @override
  ConsumerState<EditNickInput> createState() => _EditNickInputState();
}

class _EditNickInputState extends ConsumerState<EditNickInput> {
  late TextEditingController _controller;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final initialNickname = ref.read(viewmodel.userNameProvider) ?? 'null';
    _controller = TextEditingController(text: initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final existingNicknames = ['user1', 'user2', 'admin']; // 중복된 별명 체크용

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "editNick.title".tr(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("editNick.enterNickname".tr(), style: heading_medium(context)),
                    const SizedBox(height: 24),
                    NicknameTextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "editNick.nicknameLabel".tr(),
                        border: OutlineInputBorder(),
                      ),
                      existingNicknames: existingNicknames,
                      onChanged: (text, error) {
                        setState(() {
                          errorMessage = error;
                        });
                      },
                    ),
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMessage!,
                          style: body_xsmall(context).copyWith(color: customColors.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ButtonPrimary_noPadding(
              function: () async {
                final newNickname = _controller.text.trim();

                // ✅ 로컬 유효성 검사 (L10N 메시지)
                if (newNickname.isEmpty || newNickname.length > 8 || newNickname.contains(' ')) {
                  setState(() {
                    errorMessage = "editNick.error".tr();
                  });
                  return;
                }

                final result =
                await ref.read(viewmodel.userNameProvider.notifier).updateUserName(newNickname);

                if (result != null) {
                  setState(() {
                    // 서버/로직에서 온 에러 메시지는 그대로 보여줌(이미 포맷된 문자열일 수 있음)
                    errorMessage = result;
                  });
                } else {
                  if (!mounted) return;
                  Navigator.pop(context, newNickname);
                }
              },
              title: "editNick.submit".tr(),
            ),
          ),
        ],
      ),
    );
  }
}
