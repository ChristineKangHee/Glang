/// File: paragraph_analysis.dart
/// Purpose: 주제 추출 미션 메인 화면
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-1-25 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/components/my_divider.dart';
import 'package:readventure/view/feature/after_read/GA_03_08_paragraph_analysis/paragraph_analysis_result.dart';

import '../../../../theme/font.dart';
import '../../../../util/box_shadow_styles.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';
import '../courseCreating.dart';
import 'levelTest_quiz_data.dart';
import 'level_test_provider.dart';

// 문제 화면
class LevelTestParagraphAnalysis extends ConsumerStatefulWidget {
  @override
  _LevelTestParagraphAnalysisState createState() => _LevelTestParagraphAnalysisState();
}

class _LevelTestParagraphAnalysisState extends ConsumerState<LevelTestParagraphAnalysis> {
  int currentQuestionIndex = 0; // 현재 문제 번호
  int correctAnswers = 0; // 맞힌 문제 수
  List<int> userAnswers = []; // 사용자가 선택한 답 저장


  // 선택지 정답 확인 함수
  void checkAnswer(int selectedIndex) {
    final stage = ref.watch(levelTestProvider);
    final questions = stage.quizzes;
    final question = questions[currentQuestionIndex];

    setState(() {
      userAnswers.add(selectedIndex); // 선택된 답안을 저장
    });

    bool isCorrect = selectedIndex == question.correctIndex;

    if (isCorrect) {
      correctAnswers++; // 정답 카운트 증가
    }

    // 1.5초 뒤 다음 문제로 이동
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // 위젯이 dispose된 경우 방지
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CourseProcessingPage()),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(levelTestProvider);
    final questions = stage.quizzes;
    final question = questions[currentQuestionIndex];
    final customColors = ref.watch(customColorsProvider);
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: CustomAppBar_2depth_10(
        title: '문단 주제 추출', // 화면 제목
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행률 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // 끝을 둥글게 설정
              child: LinearProgressIndicator(
                value: progress, // 진행률
                backgroundColor: customColors.neutral80, // 배경색
                color: customColors.primary, // 진행 색상
                minHeight: 8,
              ),
            ),
          ),
          // 문제 표시 섹션
          QuestionSection(question, context, customColors),
          const SizedBox(height: 16),
          BigDivider(), // 구분선
          const SizedBox(height: 16),
          // 선택지 표시
          // 선택지 표시
          ...List.generate(
            question.options.length,
                (index) {
              final isSelected = userAnswers.length > currentQuestionIndex &&
                  userAnswers[currentQuestionIndex] == index; // 사용자가 선택했는지 확인
              final isCorrect = question.correctIndex == index; // 정답인지 확인
              final hasAnswered = userAnswers.length > currentQuestionIndex; // 사용자가 답을 선택했는지 확인

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // 선택지 패딩
                child: GestureDetector(
                  onTap: () {
                    if (!hasAnswered) {
                      checkAnswer(index); // 정답 확인
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasAnswered
                          ? (isCorrect
                          ? (customColors.success40 ?? Colors.green) // 정답 강조
                          : (isSelected
                          ? (customColors.error40 ?? Colors.red) // 오답 강조
                          : (customColors.neutral100 ?? Colors.grey[200])))
                          : (customColors.neutral100 ?? Colors.grey[200]), // 선택 전 기본 색상
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasAnswered
                            ? (isCorrect
                            ? (customColors.success ?? Colors.green) // 정답 선택 시 초록색 테두리
                            : (isSelected
                            ? (customColors.error ?? Colors.red) // 오답 선택 시 빨간색 테두리
                            : (customColors.neutral80 ?? Colors.grey)))
                            : (customColors.neutral80 ?? Colors.grey), // 선택 전 기본 테두리
                        width: 2,
                      ),
                    ),
                    child: Text(
                      question.options[index], // 선택지 텍스트
                      style: body_small(context),
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  // 문제 섹션 위젯
  Widget QuestionSection(LevelTestParagraph question, BuildContext context, CustomColors customColors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 번호와 질문 텍스트
          Text(
            'Q${currentQuestionIndex + 1}. 다음 중 문단의 주제로 가장 적합한 것을 골라볼까요?',
            style: body_small_semi(context).copyWith(
              color: customColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // 문단 내용
          Text(
            question.question, // 기존: question.content
            style: reading_exercise(context),
          ),
        ],
      ),
    );
  }
}
