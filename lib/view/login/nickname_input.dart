/// 파일: nickname_input.dart
/// 목적: 별명 입력 textfield 포함된 페이지
/// 작성자: 강희
/// 생성일: 2024-01-07
/// 마지막 수정: 2025-01-08 by 강희

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../components/custom_textfield.dart';

class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();
  String? errorMessage;
  final List<String> existingNicknames = ['user1', 'user2', 'admin'];

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isInputValid = _controller.text.isNotEmpty &&
        _controller.text.length >= 1 &&
        _controller.text.length <= 8 &&
        !existingNicknames.contains(_controller.text) &&
        !_controller.text.contains(' ');

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),
        resizeToAvoidBottomInset: false,
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
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child: isInputValid
                  ? ButtonPrimary(
                function: () {
                  print("별명 완료: ${_controller.text}");
                },
                title: '완료',
              )
                  : ButtonPrimary20(
                function: () {
                  print("완료되지 않음");
                },
                title: '완료',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
