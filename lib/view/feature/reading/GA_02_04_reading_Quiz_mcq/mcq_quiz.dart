/// File: mcq_quiz.dart
/// Purpose: 읽기 중 다지선다 객관식 feature 구현 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';

class McqQuiz extends StatefulWidget {
  final McqQuestion question; // 퀴즈 문제 객체
  final Function(int) onAnswerSelected; // 사용자가 선택한 답안 인덱스를 처리하는 콜백 함수
  final int? userAnswer; // 이전 답안을 표시하기 위한 선택적 매개변수

  McqQuiz({required this.question, required this.onAnswerSelected, this.userAnswer});

  @override
  _McqQuizState createState() => _McqQuizState();
}

class _McqQuizState extends State<McqQuiz> {
  int? selectedAnswerIndex; // 선택된 답안 인덱스

  @override
  void initState() {
    super.initState();
    // 이전에 선택된 답안이 있다면 그 값으로 초기화
    if (widget.userAnswer != null) {
      setState(() {
        selectedAnswerIndex = widget.userAnswer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Card(
      margin: const EdgeInsets.only(top: 16), // 카드의 위쪽 마진 설정
      shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: customColors.neutral90 ?? Colors.grey, // 카드 테두리 색상
          ),
          borderRadius: BorderRadius.circular(20)), // 카드 모서리 둥글게
      child: Padding(
        padding: const EdgeInsets.all(16), // 카드 내부 여백 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 중앙 정렬
          children: [
            Text(
              'quiz.title'.tr(), // 🔹 다국어 키 적용
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            const SizedBox(height: 24), // 제목과 문제 사이의 간격
            Align(
              alignment: Alignment.centerLeft, // 문제 텍스트 왼쪽 정렬
              child: Text(
                widget.question.paragraph, // 퀴즈 문제 텍스트
                style: body_small_semi(context).copyWith(
                  color: customColors.primary, // 문제 색상 설정
                ),
              ),
            ),
            const SizedBox(height: 20), // 문제와 옵션 사이의 간격
            Column(
              children: widget.question.options.asMap().entries.map((entry) {
                final index = entry.key; // 옵션 인덱스
                final option = entry.value; // 옵션 텍스트

                // 선택된 옵션인지 확인
                bool isSelected = selectedAnswerIndex == index;
                bool isCorrect = isSelected && index == widget.question.correctAnswerIndex;
                bool isIncorrect = isSelected && index != widget.question.correctAnswerIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswerIndex = index; // 선택된 답안 인덱스 업데이트
                    });
                    widget.onAnswerSelected(index); // 답안 선택 후 콜백 호출
                  },
                  child: Container(
                    width: double.infinity, // 옵션 버튼의 너비를 전체로 설정
                    margin: const EdgeInsets.only(bottom: 12), // 각 옵션 버튼 간의 간격
                    padding: const EdgeInsets.all(16), // 옵션 버튼 내부 여백 설정
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? customColors.success40 // 정답 선택 시 색상
                          : isIncorrect
                          ? customColors.error40 // 오답 선택 시 색상
                          : customColors.neutral100, // 기본 미선택 상태 색상
                      borderRadius: BorderRadius.circular(14), // 옵션 버튼 모서리 둥글게
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect
                            ? customColors.success ?? Colors.green // 정답 선택 시 테두리 색상
                            : customColors.error ?? Colors.red) // 오답 선택 시 테두리 색상
                            : customColors.neutral80 ?? Colors.grey, // 미선택 시 테두리 색상
                        width: 2, // 테두리 두께 설정
                      ),
                    ),
                    child: Text(
                      option, // 옵션 텍스트 표시
                      style: body_small(context), // 옵션 텍스트 스타일
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
