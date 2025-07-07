/// File: result_dialog.dart
/// Purpose: 읽기중 ox, 객관식 정답 화면 구현 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import '../../../theme/font.dart';
import '../../components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';

class ResultDialog extends StatelessWidget {
  final bool isCorrect; // 정답 여부를 나타내는 변수
  final String explanation; // 정답에 대한 설명
  final VoidCallback onCompleted; // 완료 후 실행할 콜백 함수

  const ResultDialog({
    Key? key,
    required this.isCorrect, // 정답 여부를 인자로 받음
    required this.explanation, // 설명을 인자로 받음
    required this.onCompleted, // 완료 후 실행할 콜백 함수 받음
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 커스텀 색상을 불러옴
    return AlertDialog(
      backgroundColor: customColors.neutral100, // 배경색 지정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // 자식 위젯 크기 최소화
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, // 정답/오답에 맞는 아이콘 선택
                color: isCorrect ? customColors.primary : customColors.error, // 아이콘 색상 변경
                size: 24, // 아이콘 크기 설정
              ),
              const SizedBox(width: 8), // 아이콘과 텍스트 사이에 여백 추가
              Text(
                isCorrect ? 'quiz.correct'.tr() : 'quiz.incorrect'.tr(),
                style: body_large_semi(context).copyWith(
                  color: isCorrect ? customColors.primary : customColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // 메시지와 설명 사이에 여백 추가
          Text(
            explanation, // 설명 텍스트 출력
            style: body_small(context).copyWith(
              color: customColors.neutral30, // 설명 텍스트 색상 설정
            ),
          ),
          const SizedBox(height: 20), // 설명과 버튼 사이에 여백 추가
          ButtonPrimary_noPadding(
            function: () {
              Navigator.pop(context); // 다이얼로그 닫기
              onCompleted(); // 완료 콜백 실행
            },
            title: 'common.complete'.tr(),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, bool isCorrect, String explanation, VoidCallback onCompleted) {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 눌러도 닫히지 않게 설정
      builder: (_) => ResultDialog(
        isCorrect: isCorrect, // 정답 여부 전달
        explanation: explanation, // 설명 전달
        onCompleted: onCompleted, // 완료 콜백 함수 전달
      ),
    );
  }
}
