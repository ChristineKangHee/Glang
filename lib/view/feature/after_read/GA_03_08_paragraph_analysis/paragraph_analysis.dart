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
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';

// 문제 데이터 모델 정의
class Question {
  final String content; // 문단 내용
  final List<String> options; // 선택지 리스트
  final int correctAnswerIndex; // 정답의 인덱스
  final String explanation; // 정답 설명

  // 생성자
  Question({
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.content,
  });
}

// 샘플 데이터 정의
final List<Question> questions = [
  Question(
    content: '현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다. 기존의 교육 시스템은 주로 일률적인 교재와 평가 방식을 사용하며, 이는 학습 동기를 저하시킬 위험이 있다. 또한, 읽기 과정에서 즉각적인 피드백을 제공하는 시스템이 부족하여 학습자는 자신의 약점이나 강점을 파악하기 어렵다.',
    options: ['기존 교육 시스템의 문제점', '읽기 능력의 정의와 의의', '개인화된 학습 도구의 효과', '실시간 피드백 시스템의 필요성'],
    correctAnswerIndex: 0, // 정답 인덱스
    explanation: '기존 교육 시스템의 문제점을 논의하며 현재의 한계를 설명하는 내용이 중심입니다. 다른 선택지는 구체적 방법이나 효과에 관한 주제로, 본 문단의 초점과 다릅니다.',
  ),
  Question(
    content: '맞춤형 읽기 도구와 실시간 피드백 시스템은 학습자가 적합한 자료를 통해 능동적으로 읽기 능력을 향상시키고, 스스로 학습 과정을 조율할 수 있는 환경을 제공할 잠재력이 있다. 또한, 맞춤형 읽기 도구는 학습자의 수준과 흥미를 고려하여 적합한 자료를 제공할 수 있다.',
    options: ['학습 동기 향상을 위한 도구 개발', '맞춤형 읽기 도구와 실시간 피드백 시스템의 장점', '읽기 능력 향상을 위한 전통적 방법', '교재의 일률적 내용에 대한 비판'],
    correctAnswerIndex: 1,
    explanation: '맞춤형 읽기 도구와 실시간 피드백 시스템의 장점에 대해 설명하며 해당 방법의 유용성을 강조합니다. 다른 선택지는 내용의 초점과 거리가 있습니다.',
  ),
  Question(
    content: '이러한 도구의 개발과 보급은 개인화된 학습의 미래를 열어갈 중요한 과제가 될 것이다.',
    options: ['맞춤형 도구의 개발과 활용 방안', '교육의 전통적 방식 유지 필요성', '개인화된 학습 환경 구축의 중요성', '읽기 능력 훈련을 위한 기존 교재의 개선'],
    correctAnswerIndex: 2,
    explanation: '개인화된 학습 환경을 구축해야 하는 중요성을 강조하며 이를 중심으로 논의합니다. 다른 선택지는 세부 방법이나 대안을 다루어 주제와 맞지 않습니다.',
  ),
];

// 문제 화면
class QuizScreen extends ConsumerStatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0; // 현재 문제 번호
  int correctAnswers = 0; // 맞힌 문제 수
  List<int> userAnswers = []; // 사용자가 선택한 답 저장

  // 선택지 정답 확인 함수
  void checkAnswer(int selectedIndex) {
    final customColors = ref.watch(customColorsProvider);
    final question = questions[currentQuestionIndex];

    setState(() {
      userAnswers.add(selectedIndex); // 선택된 답안을 저장
    });

    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    if (isCorrect) {
      correctAnswers++; // 정답 카운트 증가
    }

    // 정답 여부를 알려주는 BottomSheet 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: customColors.neutral100, // 배경색
          boxShadow: BoxShadowStyles.shadow1(context), // 그림자 스타일
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정답/오답 아이콘과 메시지
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect ? customColors.primary : customColors.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? '정답입니다!' : '오답입니다.',
                  style: body_large_semi(context).copyWith(
                    color: isCorrect ? customColors.primary : customColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 정답 설명
            Text(
              question.explanation,
              style: body_small(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            const SizedBox(height: 20),
            // 다음 문제로 이동 버튼
            ButtonPrimary_noPadding(
              function: () {
                Navigator.pop(context); // BottomSheet 닫기
                if (currentQuestionIndex < questions.length - 1) {
                  setState(() {
                    currentQuestionIndex++; // 다음 문제로 이동
                  });
                } else {
                  // 결과 화면 팝업 표시
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ResultScreen(
                      totalQuestions: questions.length,
                      correctAnswers: correctAnswers,
                      userAnswers: userAnswers,
                    ),
                  );
                }
              },
              title: '다음 문제',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex]; // 현재 문제 가져오기
    final customColors = ref.watch(customColorsProvider); // 사용자 정의 색상 가져오기
    final progress = (currentQuestionIndex + 1) / questions.length; // 진행률 계산

    return Scaffold(
      appBar: CustomAppBar_2depth_8(
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
              final isCorrect = question.correctAnswerIndex == index; // 정답인지 확인
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
  Widget QuestionSection(Question question, BuildContext context, CustomColors customColors) {
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
            question.content,
            style: reading_exercise(context),
          ),
        ],
      ),
    );
  }
}
