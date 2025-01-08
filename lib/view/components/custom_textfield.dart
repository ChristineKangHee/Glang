/// 파일: custom_textfield.dart
/// 목적: textfield component
/// 작성자: 강희
/// 생성일: 2024-01-08
/// 마지막 수정: 2025-01-08 by 강희

//사용 방법은 nickname_input.dart를 참고해서 사용할 것

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class NicknameTextField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> existingNicknames;
  final Function(String text, String? errorMessage) onChanged;

  const NicknameTextField({
    Key? key,
    required this.controller,
    required this.existingNicknames,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '별명',
          style: body_xsmall(context).copyWith(color: customColors.primary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: body_large_semi(context),
          cursorColor: customColors.primary ?? Colors.purple,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(5),
          decoration: InputDecoration(
            hintText: '별명을 입력하세요',
            hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: customColors.primary ?? Colors.purple,
                width: 2,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: customColors.neutral60 ?? Colors.grey,
                width: 2,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.cancel_rounded, color: customColors.neutral60 ?? Colors.grey),
              onPressed: () {
                controller.clear();
                onChanged('', null);
              },
            )
                : null,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          onChanged: (text) {
            String? error;
            if (text.length > 8) {
              controller.text = text.substring(0, 8);
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            } else if (text.contains(' ')) {
              error = '공백은 사용할 수 없어요.';
            } else if (existingNicknames.contains(text)) {
              error = '이미 사용 중인 닉네임이에요.';
            }
            onChanged(controller.text, error);
          },
        ),
      ],
    );
  }
}
