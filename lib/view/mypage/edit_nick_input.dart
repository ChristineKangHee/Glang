/// File: edit_nick.dart
/// Purpose: 사용자의 별명를 수정할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-02-12 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../components/custom_textfield.dart';
import '../../viewmodel/user_service.dart' as viewmodel;
import 'edit_profile.dart';

class EditNickInput extends ConsumerStatefulWidget {
  const EditNickInput({super.key});

  @override
  ConsumerState<EditNickInput> createState() => _EditNickInputState();
}

class _EditNickInputState extends ConsumerState<EditNickInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialNickname = ref.read(viewmodel.userNameProvider);
    _controller = TextEditingController(text: initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final existingNicknames = ['user1', 'user2', 'admin']; // 중복된 별명 체크용

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "내 정보 수정",
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
                    Text(
                      '별명을 입력해주세요',
                      style: heading_medium(context),
                    ),
                    const SizedBox(height: 24),
                    NicknameTextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: '별명',
                        border: OutlineInputBorder(),
                      ),
                      existingNicknames: existingNicknames,
                      onChanged: (text, error) {
                        setState(() {
                          errorMessage = error;
                        });
                      },
                    ),
                    if (errorMessage != null)
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
            child: ButtonPrimary(
              function: () {
                if (_controller.text.isNotEmpty &&
                    _controller.text.length <= 8 &&
                    !_controller.text.contains(' ') &&
                    !existingNicknames.contains(_controller.text)) {
                  // 별명 상태 업데이트
                  ref.read(viewmodel.userNameProvider.notifier).updateUserName(_controller.text);
                  // 이전 페이지로 돌아가기
                  Navigator.pop(context, _controller.text);
                } else {
                  setState(() {
                    errorMessage = '별명은 1-8자 이내로 공백 없이 입력해주세요.';
                  });
                }
              },
              title: '완료',
            ),
          ),
        ],
      ),
    );
  }
}