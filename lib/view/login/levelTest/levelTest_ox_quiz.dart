/// 파일: ox_quiz.dart
/// 목적: 읽기 중 OX 퀴즈 기능 구현 코드
/// 작성자: 강희
/// 작성일: 2024-1-19
/// 최종 수정일: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';

import 'levelTest_quiz_data.dart';

class levelTestOxQuiz extends StatefulWidget {
  final LevelTestOxQuestion question; // 퀴즈 질문 데이터
  final Function(bool) onAnswerSelected; // 사용자가 선택한 답을 처리하는 콜백 함수
  final bool? userAnswer; // 이전에 선택한 답안 (선택된 경우 표시)

  levelTestOxQuiz({required this.question, required this.onAnswerSelected, this.userAnswer});

  @override
  _levelTestOxQuizState createState() => _levelTestOxQuizState();
}

class _levelTestOxQuizState extends State<levelTestOxQuiz> {
  List<bool> userAnswers = []; // 사용자가 선택한 답들을 저장하는 리스트
  int currentQuestionIndex = 0; // 현재 문제의 인덱스

  @override
  void initState() {
    super.initState();
    // 초기 상태에서 userAnswer가 주어지면 그 값을 반영
    if (widget.userAnswer != null) {
      setState(() {
        if (userAnswers.isEmpty) {
          userAnswers.add(widget.userAnswer!); // 첫 번째 답을 추가
        } else {
          userAnswers[currentQuestionIndex] = widget.userAnswer!; // 기존에 선택된 답을 업데이트
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 커스텀 테마 색상 가져오기

    // 커스텀 색상이 null일 경우 기본 색상을 지정
    Color successColor = customColors.success ?? Colors.green;
    Color errorColor = customColors.error ?? Colors.red;
    Color neutralColor = customColors.neutral100 ?? Colors.grey;
    Color neutralBorderColor = customColors.neutral80 ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(top: 16), // 카드 위쪽 마진
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: customColors.neutral90 ?? Colors.grey, // 카드 테두리 색상
        ),
        borderRadius: BorderRadius.circular(20), // 카드 모서리 둥글게
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // 카드 내 여백
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 컬럼 가운데 정렬
          children: [
            // 수정 후
            Text(
              'quiz.title'.tr(),
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft, // 질문 텍스트 왼쪽 정렬
              child: Text(
                widget.question.paragraph, // 퀴즈 질문
                style: body_small_semi(context).copyWith(
                  color: customColors.primary, // 질문 색상
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 'O'와 'X' 버튼을 사용자 정의 디자인으로 변경
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userAnswers.length <= currentQuestionIndex) {
                        widget.onAnswerSelected(true); // 'O' 선택 시
                        setState(() {
                          userAnswers.add(true); // 'O' 답을 리스트에 추가
                        });
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1, // 비율 1:1
                      child: Container(
                        margin: const EdgeInsets.only(right: 8), // 오른쪽 마진
                        padding: const EdgeInsets.all(16), // 내부 여백
                        decoration: BoxDecoration(
                          color: userAnswers.length > currentQuestionIndex &&
                              userAnswers[currentQuestionIndex] == true
                              ? (widget.question.correctAnswer
                              ? customColors.success40 // 정답일 경우 성공 색상
                              : customColors.error40) // 오답일 경우 실패 색상
                              : customColors.neutral100, // 기본 색상
                          borderRadius: BorderRadius.circular(14), // 버튼 모서리 둥글게
                          border: Border.all(
                            color: userAnswers.length > currentQuestionIndex &&
                                userAnswers[currentQuestionIndex] == true
                                ? (widget.question.correctAnswer
                                ? customColors.success ?? Colors.green
                                : customColors.error ?? Colors.red)
                                : customColors.neutral80 ?? neutralBorderColor, // 테두리 색상
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle_outlined, // 'O' 버튼 아이콘
                            color: successColor,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userAnswers.length <= currentQuestionIndex) {
                        widget.onAnswerSelected(false); // 'X' 선택 시
                        setState(() {
                          userAnswers.add(false); // 'X' 답을 리스트에 추가
                        });
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1, // 비율 1:1
                      child: Container(
                        margin: const EdgeInsets.only(left: 8), // 왼쪽 마진
                        padding: const EdgeInsets.all(16), // 내부 여백
                        decoration: BoxDecoration(
                          color: userAnswers.length > currentQuestionIndex &&
                              userAnswers[currentQuestionIndex] == false
                              ? (!widget.question.correctAnswer
                              ? customColors.success40 // 오답일 경우 성공 색상
                              : customColors.error40) // 정답일 경우 실패 색상
                              : neutralColor, // 기본 색상
                          borderRadius: BorderRadius.circular(14), // 버튼 모서리 둥글게
                          border: Border.all(
                            color: userAnswers.length > currentQuestionIndex &&
                                userAnswers[currentQuestionIndex] == false
                                ? (!widget.question.correctAnswer
                                ? customColors.success ?? Colors.green
                                : customColors.error ?? Colors.red)
                                : customColors.neutral80 ?? neutralBorderColor, // 테두리 색상
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded, // 'X' 버튼 아이콘
                            color: customColors.error,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
