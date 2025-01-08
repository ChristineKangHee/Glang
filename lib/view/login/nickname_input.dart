/// 파일: nickname_input.dart
/// 목적: 별명 입력 textfield 포함된 페이지
/// 작성자: 강희
/// 생성일: 2024-01-07
/// 마지막 수정: 2025-01-08 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

/// 별명 입력 페이지의 위젯 정의
class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

/// 별명 입력 페이지의 상태 클래스
class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController(); // 별명 입력 필드의 컨트롤러
  String? errorMessage; // 오류 메시지를 저장하는 변수
  final List<String> existingNicknames = ['user1', 'user2', 'admin']; // 기존에 사용 중인 별명 목록

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 사용자 정의 테마 색상
    final hasError = errorMessage != null; // 오류 상태 여부
    final isInputNotEmpty = _controller.text.isNotEmpty; // 입력 필드가 비어 있지 않은지 확인

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(), // 커스텀 로고 앱바
        resizeToAvoidBottomInset: false, // 키보드로 인해 레이아웃이 바뀌지 않도록 설정
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 페이지 제목
                      Text(
                        '별명을 입력해주세요',
                        style: heading_medium(context),
                      ),
                      const SizedBox(height: 24),

                      // 입력 필드 제목
                      Text(
                        '별명',
                        style: body_xsmall(context).copyWith(color: customColors.primary),
                      ),
                      const SizedBox(height: 8),

                      // 별명 입력 필드
                      TextField(
                        controller: _controller,
                        style: body_large_semi(context), // 텍스트 스타일
                        cursorColor: customColors.primary ?? Colors.purple, // 커서 색상
                        cursorWidth: 2, // 커서 두께
                        cursorRadius: Radius.circular(5), // 커서의 둥근 모서리
                        decoration: InputDecoration(
                          hintText: '별명을 입력하세요', // 힌트 텍스트
                          hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: hasError
                                  ? customColors.error ?? Colors.red
                                  : customColors.primary ?? Colors.purple,
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: hasError
                                  ? customColors.error ?? Colors.red
                                  : customColors.neutral60 ?? Colors.grey,
                              width: 2,
                            ),
                          ),
                          suffixIcon: isInputNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded, color: customColors.neutral60 ?? Colors.purple),
                            onPressed: () {
                              _controller.clear(); // 입력 필드 초기화
                              setState(() {
                                errorMessage = null; // 오류 메시지 초기화
                              });
                            },
                          )
                              : null,
                        ),
                        onChanged: (text) {
                          setState(() {
                            // 입력된 텍스트가 기존 별명에 포함되는지 확인
                            if (existingNicknames.contains(text)) {
                              errorMessage = '이미 사용 중인 닉네임이에요';
                            } else {
                              errorMessage = null;
                            }
                          });
                        },
                      ),

                      // 오류 메시지 출력
                      if (hasError)
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

            // 완료 버튼
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child: hasError || !isInputNotEmpty
                  ? ButtonPrimary20(
                function: () {
                  print("완료");
                },
                title: '완료',
              )
                  : ButtonPrimary(
                function: () {
                  print("완료");
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
