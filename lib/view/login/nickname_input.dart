/// File: nickname_input.dart
/// Purpose: 별명 입력 및 검증을 위한 UI 구현, Firestore를 통해 닉네임 중복 확인 및 저장 처리
/// Author: 박민준
/// Created: 2025-01-06
/// Last Modified: 2025-01-07 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../components/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/DoubleBackToExitWrapper.dart';

//TODO: Error Message 출력(닉네임 겹칠)시 버튼 색 바뀌게하기

class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isInputValid = _controller.text.isNotEmpty &&
        _controller.text.length >= 1 &&
        _controller.text.length <= 8 &&
        !_controller.text.contains(' ');

    Future<void> _saveNickname() async {
      setState(() {
        isLoading = true; // 로딩 상태 활성화
      });

      final nickname = _controller.text.trim();
      final user = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자 가져오기

      if (user != null) {
        try {
          // Firestore에서 기존 닉네임 확인
          final nicknameDoc = FirebaseFirestore.instance.collection('nicknames').doc(nickname);
          final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

          final snapshot = await nicknameDoc.get();
          if (snapshot.exists) {
            // 닉네임이 이미 존재하는 경우
            setState(() {
              errorMessage = 'nickname.duplicate_error'.tr();
            });
          } else {
            // Firestore에 닉네임 저장 및 사용자 상태 업데이트
            await nicknameDoc.set({'uid': user.uid, 'created_at': FieldValue.serverTimestamp()});
            await userDoc.update({
              'nickname': nickname,
              'nicknameSet': true, // 닉네임 설정 완료 상태 업데이트
            });

            // 성공 시 홈 화면으로 이동
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/tutorial');
            }
          }
        } catch (e) {
          setState(() {
            errorMessage = 'nickname.save_error'.tr();
          });
          print('별명 저장 오류: $e');
        } finally {
          setState(() {
            isLoading = false; // 로딩 상태 비활성화
          });
        }
      } else {
        setState(() {
          errorMessage = 'nickname.auth_error'.tr();
        });
      }
    }

    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'nickname.title'.tr(),
                          style: heading_medium(context),
                        ),
                        const SizedBox(height: 24),
                        NicknameTextField(
                          controller: _controller,
                          existingNicknames: [], // Firestore에서 가져오기 때문에 불필요
                          onChanged: (text, error) {
                            setState(() {
                              errorMessage = null; // 입력 중 에러 메시지 초기화
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
                child: isInputValid && !isLoading
                    ? ButtonPrimary_noPadding(
                  function: _saveNickname,
                    title: 'common.complete'.tr()
                )
                    : ButtonPrimary20_noPadding(
                  function: () {
                    setState(() {
                      errorMessage = 'nickname.invalid_input'.tr();
                    });
                  },
                    title: 'common.complete'.tr()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
