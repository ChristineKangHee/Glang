/// File: nickname_input.dart
/// Purpose: 별명 입력 화면 구현
/// Author: 강희
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '별명을 입력해주세요',
                style: heading_medium(context),
              ),
              const SizedBox(height: 24),
              Text(
                '별명',
                style: body_xsmall(context).copyWith(color: customColors.primary),
              ),
              const SizedBox(height: 8),
              TextField(
                style: body_large_semi(context),  // Set the text style for the input text
                decoration: InputDecoration(
                  hintText: '별명을 입력하세요',
                  hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: customColors.primary ?? Colors.blue, width: 2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: customColors.neutral60 ?? Colors.grey, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
