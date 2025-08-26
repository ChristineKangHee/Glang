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
        isLoading = true;
        errorMessage = null;
      });

      final raw = _controller.text;
      final nickname = raw.trim();
      final user = FirebaseAuth.instance.currentUser;

      // 프런트 검증 한번 더(1~8자, 공백 없음)
      final valid = nickname.isNotEmpty &&
          nickname.length >= 1 &&
          nickname.length <= 8 &&
          !nickname.contains(' ');
      if (!valid) {
        setState(() {
          isLoading = false;
          errorMessage = '별명을 올바르게 입력해주세요.';
        });
        return;
      }

      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = '사용자 인증 정보를 확인할 수 없습니다.';
        });
        return;
      }

      final fs = FirebaseFirestore.instance;
      final nickRef = fs.collection('nicknames').doc(nickname);
      final userRef = fs.collection('users').doc(user.uid);

      try {
        await fs.runTransaction((tx) async {
          // 1) 닉네임 중복 확인
          final nickSnap = await tx.get(nickRef);
          if (nickSnap.exists) {
            throw Exception('이미 사용 중인 별명입니다.');
          }

          // 2) 유저 문서 upsert
          final userSnap = await tx.get(userRef);
          if (!userSnap.exists) {
            // 최소 스키마로 생성 (필요한 필드는 프로젝트 스키마에 맞게 추가)
            tx.set(userRef, {
              'name': user.displayName,
              'photoURL': user.photoURL,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
              'totalXP': 0,
              'currentCourse': '코스1',
              'learningTime': 0,
              'completedMissionCount': 0,
              // 닉네임 필드 동시 반영
              'nickname': nickname,
              'nicknameSet': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            // 존재하면 닉네임/플래그만 업데이트
            tx.update(userRef, {
              'nickname': nickname,
              'nicknameSet': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          // 3) 닉네임 점유 문서 생성
          tx.set(nickRef, {
            'uid': user.uid,
            'created_at': FieldValue.serverTimestamp(),
          });
        });

        // 성공 → 튜토리얼로 이동
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/tutorial');
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString().contains('이미 사용 중인 별명')
              ? '이미 사용 중인 별명입니다.'
              : '별명을 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.';
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
                        Text(
                          '별명을 입력해주세요',
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
                  title: '완료',
                )
                    : ButtonPrimary20_noPadding(
                  function: () {
                    setState(() {
                      errorMessage = '별명을 올바르게 입력해주세요.';
                    });
                  },
                  title: '완료',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
