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

// 문제 데이터 모델
class Question {
  final String paragraph; // 문단 내용
  final List<String> options; // 선택지
  final int correctAnswerIndex; // 정답의 인덱스
  final String explanation; // 정답 설명

  Question({
    required this.paragraph,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

// 샘플 데이터
final List<Question> questions = [
  Question(
    paragraph: '문단 1 내용입니다. 이 문단의 핵심 주제는 무엇일까요?',
    options: ['주제 1', '주제 2', '주제 3', '주제 4'],
    correctAnswerIndex: 1,
    explanation: '문단의 핵심은 "주제 2"입니다. 주어진 문장을 보면 ...',
  ),
  Question(
    paragraph: '문단 2 내용입니다. 다음 문단의 주제를 선택하세요.',
    options: ['주제 A', '주제 B', '주제 C', '주제 D'],
    correctAnswerIndex: 2,
    explanation: '문단의 핵심은 "주제 C"입니다. 여기에서 중요한 부분은 ...',
  ),
  Question(
    paragraph: '문단 3 내용입니다. 문단의 핵심 주제는 무엇인가요?',
    options: ['주제 X', '주제 Y', '주제 Z', '주제 W'],
    correctAnswerIndex: 0,
    explanation: '문단의 핵심은 "주제 X"입니다. 추가 설명으로는 ...',
  ),
];

// 문제 화면
class QuizScreen extends ConsumerStatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  List<int> userAnswers = []; // 사용자가 선택한 답 저장

  void checkAnswer(int selectedIndex) {
    final customColors = ref.watch(customColorsProvider);
    final question = questions[currentQuestionIndex];

    setState(() {
      userAnswers.add(selectedIndex); // 선택된 답안을 저장
    });

    bool isCorrect = selectedIndex == question.correctAnswerIndex;

    if (isCorrect) {
      correctAnswers++;
    }

    // BottomSheet 표시
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
          color: customColors.neutral100,
          boxShadow: BoxShadowStyles.shadow1(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              question.explanation,
              style: body_small(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            const SizedBox(height: 20),
            ButtonPrimary(
              function: () {
                Navigator.pop(context); // BottomSheet 닫기
                if (currentQuestionIndex < questions.length - 1) {
                  setState(() {
                    currentQuestionIndex++;
                  });
                } else {
                  // 결과 화면을 팝업으로 표시
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
    final question = questions[currentQuestionIndex];
    final customColors = ref.watch(customColorsProvider);
    final progress = (currentQuestionIndex + 1) / questions.length; // 진행률 계산

    return Scaffold(
      appBar: CustomAppBar_2depth_8(
        title: '문단 주제 추출',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar 추가
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // 끝을 둥글게 설정
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: customColors.neutral80,
                color: customColors.primary,
                minHeight: 8,
              ),
            ),
          ),
          QuestionSection(question, context, customColors),
          const SizedBox(height: 16),
          BigDivider(),
          const SizedBox(height: 16),
          ...List.generate(
            question.options.length,
                (index) {
              final isSelected = userAnswers.length > currentQuestionIndex &&
                  userAnswers[currentQuestionIndex] == index;
              final isCorrect = question.correctAnswerIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // 여기에서 패딩 적용
                child: GestureDetector(
                  onTap: () {
                    if (userAnswers.length <= currentQuestionIndex) {
                      checkAnswer(index);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isCorrect
                          ? (customColors.success40 ?? Colors.green)
                          : (customColors.error40 ?? Colors.red))
                          : (customColors.neutral100 ?? Colors.grey[200]),
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
                    child: Text(
                      question.options[index],
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


  Widget QuestionSection(Question question, BuildContext context, CustomColors customColors) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${currentQuestionIndex + 1}. ${question.paragraph}',
                    style: body_small_semi(context).copyWith(
                      color: customColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '디지털 기술의 발전은 우리의 일상생활을 크게 변화시켰습니다. 스마트폰과 인터넷의 보급으로 정보의 접근성이 향상되었고, 온라인 쇼핑과 디지털 결제가 일상화되었습니다. 이러한 변화는 편리함을 가져다주었지만, 동시에 새로운 문제들도 발생시켰습니다. ',
                      style: reading_exercise(context),
                  ),
                ],
              ),
    );
  }
}
