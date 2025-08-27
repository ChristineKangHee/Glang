/// File: nickname_input.dart
/// Purpose: 별명 입력 및 검증 UI, Firestore 트랜잭션으로 닉네임 중복 확인 및 저장
/// Author: 박민준
/// Created: 2025-01-06
/// Last Modified: 2025-08-27 by ChatGPT (merge conflict resolved)

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

// TODO: Error Message 출력(닉네임 겹칠)시 버튼 색 바뀌게 하기

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
        isLoading = true;
        errorMessage = null;
      });

      final raw = _controller.text;
      final nickname = raw.trim();
      final user = FirebaseAuth.instance.currentUser;

      // 0) 프런트 1차 검증 (1~8자, 공백 없음)
      final valid = nickname.isNotEmpty &&
          nickname.length >= 1 &&
          nickname.length <= 8 &&
          !nickname.contains(' ');
      if (!valid) {
        setState(() {
          isLoading = false;
          errorMessage = 'nickname.invalid_input'.tr(); // "별명을 올바르게 입력해주세요."
        });
        return;
      }

      // 1) 인증 체크
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'nickname.auth_error'.tr(); // "사용자 인증 정보를 확인할 수 없습니다."
        });
        return;
      }

      // 2) Firestore 트랜잭션: 닉네임 점유 + 유저 문서 업데이트
      final fs = FirebaseFirestore.instance;
      final nickRef = fs.collection('nicknames').doc(nickname);
      final userRef = fs.collection('users').doc(user.uid);

      try {
        await fs.runTransaction((tx) async {
          // (a) 닉네임 중복 확인
          final nickSnap = await tx.get(nickRef);
          if (nickSnap.exists) {
            // 커스텀 에러 토큰으로 던져서 구분 처리
            throw Exception('DUPLICATE_NICKNAME');
          }

          // (b) 유저 문서 upsert (최소 스키마, 프로젝트에 맞게 조정)
          final userSnap = await tx.get(userRef);
          if (!userSnap.exists) {
            tx.set(userRef, {
              'name': user.displayName,
              'photoURL': user.photoURL,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
              'totalXP': 0,
              'currentCourse': '코스1',
              'learningTime': 0,
              'completedMissionCount': 0,
              'nickname': nickname,
              'nicknameSet': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            tx.update(userRef, {
              'nickname': nickname,
              'nicknameSet': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          // (c) 닉네임 점유 문서 생성
          tx.set(nickRef, {
            'uid': user.uid,
            'created_at': FieldValue.serverTimestamp(),
          });
        });

        // 성공 → 튜토리얼 화면으로 이동
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/tutorial');
        }
      } catch (e) {
        setState(() {
          if (e.toString().contains('DUPLICATE_NICKNAME')) {
            errorMessage = 'nickname.duplicate_error'.tr(); // "이미 사용 중인 별명입니다."
          } else {
            errorMessage = 'nickname.save_error'.tr(); // "별명을 저장하는 중 문제가 발생했습니다."
          }
        });
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
                        Text('nickname.title'.tr(), style: heading_medium(context)),
                        const SizedBox(height: 24),
                        NicknameTextField(
                          controller: _controller,
                          existingNicknames: const [], // Firestore에서 확인하므로 불필요
                          onChanged: (text, err) {
                            setState(() {
                              errorMessage = null; // 입력 시 에러 제거
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
                child: (isInputValid && !isLoading)
                    ? ButtonPrimary_noPadding(
                  function: _saveNickname,
                  title: 'common.complete'.tr(),
                )
                    : ButtonPrimary20_noPadding(
                  function: () {
                    setState(() {
                      errorMessage = 'nickname.invalid_input'.tr();
                    });
                  },
                  title: 'common.complete'.tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
