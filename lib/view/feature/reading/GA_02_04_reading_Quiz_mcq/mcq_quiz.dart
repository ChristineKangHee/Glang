/// File: mcq_quiz.dart
/// Purpose: 읽기 중 다지선다 객관식 feature (1회만 응답 허용)
/// Author: 강희
/// Created: 2024-01-19
/// Last Modified: 2025-10-02 by GPT-5 Thinking

import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';

class McqQuiz extends StatefulWidget {
  final McqQuestion question;          // 퀴즈 문제 객체
  final Function(int) onAnswerSelected; // 선택한 답안 인덱스 콜백
  final int? userAnswer;               // 이전 답안(있으면 표시)
  final bool isLocked;                 // ✅ 이미 풀었는지(잠금 여부)

  const McqQuiz({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    this.userAnswer,
    this.isLocked = false,
  });

  @override
  _McqQuizState createState() => _McqQuizState();
}

class _McqQuizState extends State<McqQuiz> {
  int? selectedAnswerIndex; // 사용자가 이번 세션에서 선택한 답

  bool get locked =>
      widget.isLocked || selectedAnswerIndex != null || widget.userAnswer != null;

  int? get effectiveAnswer => selectedAnswerIndex ?? widget.userAnswer;

  @override
  void initState() {
    super.initState();
    // 이전에 저장된 답이 있으면 초기 반영(잠금)
    if (widget.userAnswer != null) {
      selectedAnswerIndex = widget.userAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2, color: customColors.neutral90 ?? Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'quiz.title'.tr(),
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(color: customColors.neutral30),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.question.paragraph,
                style: body_small_semi(context).copyWith(color: customColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: widget.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                final isSelected = effectiveAnswer == index;
                final isCorrect = isSelected && index == widget.question.correctAnswerIndex;
                final isIncorrect = isSelected && index != widget.question.correctAnswerIndex;

                return GestureDetector(
                  onTap: locked
                      ? null // ✅ 이미 답했으면 탭 비활성화
                      : () {
                    setState(() {
                      selectedAnswerIndex = index; // 첫 선택만 반영
                    });
                    // 부모에서 결과 처리(다이얼로그, 잠금 플래그 등)
                    widget.onAnswerSelected(index);
                  },
                  child: Opacity(
                    opacity: locked ? 1.0 : 1.0, // 잠금이어도 스타일만 다르게, 투명도는 유지
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? customColors.success40
                            : isIncorrect
                            ? customColors.error40
                            : customColors.neutral100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect
                              ? (customColors.success ?? Colors.green)
                              : (customColors.error ?? Colors.red))
                              : (customColors.neutral80 ?? Colors.grey),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(option, style: body_small(context)),
                          ),
                          if (locked && isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                            ),
                        ],
                      ),
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
