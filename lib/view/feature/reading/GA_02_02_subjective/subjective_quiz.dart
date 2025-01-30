/// File: subjective_quiz.dart
/// Purpose: 읽기 중 주관식 feature 구현 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import '../../../components/custom_button.dart';
import '../../after_read/widget/answer_section.dart';

class SubjectiveQuiz extends StatefulWidget {
  final TextEditingController controller; // 텍스트 필드 컨트롤러
  final Function() onSubmit; // 제출 버튼 클릭 시 호출되는 함수
  final String? initialAnswer; // 초기 답변 (선택 사항)
  final bool enabled; // 상태가 활성화된 경우

  const SubjectiveQuiz({
    required this.controller,
    required this.onSubmit,
    this.initialAnswer,
    required this.enabled,
  });

  @override
  _SubjectiveQuizState createState() => _SubjectiveQuizState();
}

class _SubjectiveQuizState extends State<SubjectiveQuiz> {
  bool _isTextFieldEmpty = true; // 텍스트 필드가 비어있는지 여부
  bool _showProblem = false; // 문제 표시 여부
  bool _isTextHighlighted = false; // 텍스트 강조 여부
  bool _isSubmitted = false; // 답변 제출 여부

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswer != null) {
      widget.controller.text = widget.initialAnswer!; // 초기 답변을 설정
    }
    widget.controller.addListener(_onTextChanged); // 텍스트가 변경될 때마다 상태 갱신
  }

  // 텍스트 필드 값이 변경될 때마다 호출되는 함수
  void _onTextChanged() {
    setState(() {
      _isTextFieldEmpty = widget.controller.text.isEmpty; // 텍스트 필드가 비었는지 확인
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 커스텀 색상 테마

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16), // 카드 간격 설정
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2, color: customColors.neutral90 ?? Colors.grey), // 카드 테두리 색상 설정
        borderRadius: BorderRadius.circular(20), // 카드 모서리 둥글기 설정
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // 카드 안쪽 여백
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 정렬 방식 설정
          children: [
            Text(
              '핵심 내용 질문', // 질문 제목
              textAlign: TextAlign.center, // 제목 중앙 정렬
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30, // 텍스트 색상 설정
              ),
            ),
            SizedBox(height: 24), // 제목과 질문 간 간격
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '실시간 피드백 시스템은 학습자에게 어떤 도움을 주나요?', // 질문 내용
                style: body_small_semi(context).copyWith(
                  color: customColors.primary, // 질문 텍스트 색상
                ),
              ),
            ),

            const SizedBox(height: 12), // 질문과 답변 입력 필드 간 간격
            // Answer_Section_No_Title에 disabled 상태 전달
            Answer_Section_No_Title(
              controller: widget.controller,
              customColors: customColors,
            ),
            const SizedBox(height: 12), // 답변 입력 필드와 버튼 간 간격
            if (!_isSubmitted) // 제출 후 버튼 숨기기 조건
              Container(
                width: MediaQuery.of(context).size.width, // 버튼 너비 설정
                child: _isTextFieldEmpty // 텍스트 필드가 비어있는지 여부에 따라 버튼 상태 변경
                    ? ButtonPrimary20_noPadding(
                  function: () {
                    print("텍스트를 입력해주세요."); // 텍스트 입력을 요청하는 로그
                  },
                  title: '제출하기', // 버튼 제목
                )
                    : ButtonPrimary_noPadding(
                  function: () {
                    setState(() {
                      _showProblem = false; // 문제 표시 여부 초기화
                      _isTextHighlighted = false; // 텍스트 강조 초기화
                      _isSubmitted = true; // 답변 제출 상태로 변경
                    });
                    widget.onSubmit(); // 제출 함수 호출
                  },
                  title: '제출하기', // 버튼 제목
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged); // 텍스트 필드 리스너 제거
    super.dispose();
  }
}
