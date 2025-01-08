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

class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();  // 사용자 입력을 관리하는 컨트롤러
  String? errorMessage;  // 유효성 검사 실패 시 오류 메시지를 저장하는 변수
  final List<String> existingNicknames = ['user1', 'user2', 'admin'];  // 이미 사용 중인 별명 목록

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;  // 앱의 색상 테마를 가져옴
    final hasError = errorMessage != null;  // 오류 메시지가 있을 경우 true
    final isInputValid = _controller.text.isNotEmpty &&  // 입력값이 비어있지 않음
        _controller.text.length >= 1 &&  // 별명 길이가 1자 이상
        _controller.text.length <= 8 &&  // 별명 길이가 8자 이하
        !existingNicknames.contains(_controller.text) &&  // 이미 사용 중인 별명이 아님
        !_controller.text.contains(' ');  // 공백이 포함되지 않음

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),  // 커스텀 앱바
        resizeToAvoidBottomInset: false,  // 키보드가 화면을 가리지 않도록 설정
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
                        '별명을 입력해주세요',  // 화면에 표시될 제목 텍스트
                        style: heading_medium(context),  // 제목 스타일
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '별명',  // 별명 입력 필드를 위한 레이블
                        style: body_xsmall(context).copyWith(color: customColors.primary),  // 스타일 적용
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,  // 입력 컨트롤러 연결
                        style: body_large_semi(context),  // 입력 텍스트 스타일
                        cursorColor: customColors.primary ?? Colors.purple,  // 커서 색상
                        cursorWidth: 2,  // 커서 너비
                        cursorRadius: const Radius.circular(5),  // 커서 라운딩
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')), // 공백 제거
                          LengthLimitingTextInputFormatter(8), // 최대 글자 수 제한
                        ],
                        decoration: InputDecoration(
                          hintText: '별명을 입력하세요',  // 입력란 힌트 텍스트
                          hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),  // 힌트 스타일
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: hasError
                                  ? customColors.error ?? Colors.red  // 오류 시 빨간색
                                  : customColors.primary ?? Colors.purple,  // 정상 시 기본 색상
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: hasError
                                  ? customColors.error ?? Colors.red  // 오류 시 빨간색
                                  : customColors.neutral60 ?? Colors.grey,  // 정상 시 회색
                              width: 2,
                            ),
                          ),
                          suffixIcon: _controller.text.isNotEmpty  // 텍스트가 입력되면 취소 버튼 표시
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded, color: customColors.neutral60 ?? Colors.grey),
                            onPressed: () {
                              _controller.clear();  // 입력값 초기화
                              setState(() {
                                errorMessage = null;  // 오류 메시지 초기화
                              });
                            },
                          )
                              : null,
                        ),
                        onChanged: (text) {
                          setState(() {
                            // 텍스트가 변경될 때마다 유효성 검사
                            if (text.isEmpty) {
                              errorMessage = null;  // 입력이 없으면 오류 메시지 초기화
                            } else if (text.length < 1) {
                              errorMessage = '별명은 최소 1자 이상이어야 해요.';  // 최소 1자
                            } else if (text.length > 8) {
                              errorMessage = '별명은 최대 8자까지만 가능해요.';  // 최대 8자
                            } else if (text.contains(' ')) {
                              errorMessage = '공백은 사용할 수 없어요.';  // 공백 포함 불가
                            } else if (existingNicknames.contains(text)) {
                              errorMessage = '이미 사용 중인 닉네임이에요.';  // 중복된 닉네임
                            } else {
                              errorMessage = null;  // 오류 없으면 초기화
                            }
                          });
                        },
                      ),
                      if (hasError)  // 오류 메시지 표시
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorMessage!,  // 오류 메시지 출력
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
              child: isInputValid  // 유효성 검사 결과에 따라 버튼 상태 변경
                  ? ButtonPrimary(
                function: () {
                  print("별명 완료: ${_controller.text}");  // 별명 완료 시 콘솔 출력
                },
                title: '완료',  // 버튼 텍스트
              )
                  : ButtonPrimary20(
                function: () {
                  print("완료되지 않음");  // 유효성 검사 실패 시 콘솔 출력
                },
                title: '완료',  // 버튼 텍스트
              ),
            ),
          ],
        ),
      ),
    );
  }
}
