/// File: writing_form_learning.dart
/// Purpose: 문장 구조 연습 화면을 구성하는 코드
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-1-25 by 강희


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/font.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import 'package:readventure/theme/theme.dart';
import '../../../components/my_divider.dart';

// 문장 구조를 관리하는 상태 제공자
final structureProvider = StateProvider<String>((ref) {
  return "○○은 ○○에서 가장 ○○한 인물이다"; // 초기 문장 구조 설정
});

// 빈칸 개수에 따라 TextEditingController를 동적으로 생성하는 제공자
final controllersProvider = Provider<Map<int, TextEditingController>>((ref) {
  final structure = ref.watch(structureProvider); // 현재 문장 구조 가져오기
  final blankCount = "○○".allMatches(structure).length; // 빈칸의 개수 계산
  final controllers = <int, TextEditingController>{};
  for (int i = 0; i < blankCount; i++) {
    controllers[i] = TextEditingController(); // 빈칸마다 TextEditingController 생성
  }
  return controllers;
});

// 문장 구조 연습 화면을 위한 StatefulWidget
class SentencePractice extends ConsumerStatefulWidget {
  @override
  _SentencePracticeState createState() => _SentencePracticeState();
}

// SentencePractice의 상태 관리 클래스
class _SentencePracticeState extends ConsumerState<SentencePractice> {
  // 화면 해제 시 TextEditingController도 메모리에서 해제
  @override
  void dispose() {
    final controllers = ref.read(controllersProvider); // 모든 컨트롤러 가져오기
    controllers.forEach((_, controller) => controller.dispose()); // 해제 처리
    super.dispose();
  }

  // 모든 입력 필드가 채워졌는지 확인하는 메서드
  bool _areFieldsFilled() {
    final controllers = ref.read(controllersProvider);
    return controllers.values.every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider); // 사용자 정의 색상 가져오기
    final structure = ref.watch(structureProvider); // 현재 문장 구조 가져오기
    final controllers = ref.watch(controllersProvider); // 컨트롤러 상태 가져오기

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: '문장 구조 연습'),
      body: SafeArea(
        child: Column(
          children: [
            ExampleForm(context, customColors, structure),
            SizedBox(height: 24),
            BigDivider(),
            SizedBox(height: 24),
            MyAnswer(context, structure),
            Spacer(),
            SubmitButton(context),
            SizedBox(height: 16,)
          ],
        ),
      ),
    );
  }

  // 사용자의 답안을 작성하는 컨테이너
  Container MyAnswer(BuildContext context, String structure) {
    final blanks = structure.split("○○"); // 빈칸 기준으로 문장 분리
    final controllers = ref.read(controllersProvider); // 컨트롤러 상태 가져오기

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "나의 답변",
            style: body_medium_semi(context), // 스타일 적용
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 12, // 빈칸 간격 설정
            runSpacing: 8, // 줄 바꿈 간격 설정
            children: List.generate(
              blanks.length + controllers.length, // 텍스트와 필드 개수 계산
                  (index) => index.isOdd
                  ? _buildTextField(index ~/ 2) // 빈칸에 대응하는 TextField 생성
                  : Text(
                blanks[index ~/ 2], // 빈칸 사이의 텍스트 출력
                style: body_small(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 제출 버튼 컨테이너
  Container SubmitButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: _areFieldsFilled() // 필드가 모두 채워졌는지 확인
          ? ButtonPrimary(
        function: () {
          print("제출하기");
          Navigator.popUntil(
            context,
                (route) => route.settings.name == 'LearningActivitiesPage', // 특정 화면으로 이동
          );
        },
        title: '제출하기',
      )
          : ButtonPrimary20(
        function: () {}, // 아무 작업도 하지 않음
        title: '제출하기',
      ),
    );
  }

  // 예시 문장을 보여주는 폼
  Widget ExampleForm(BuildContext context, CustomColors customColors, String structure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              '맥락에 맞게 문장의 빈칸을 채워볼까요?',
              style: body_small_semi(context).copyWith(color: customColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: customColors.neutral90,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '예시문장',
                    style: body_xsmall(context),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      children: _buildExampleText(structure, customColors, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 예시 문장을 TextSpan으로 구성하는 메서드
  List<InlineSpan> _buildExampleText(
      String structure, CustomColors customColors, BuildContext context) {
    final exampleWords = ["아인슈타인", "물리학", "영향력 있는"]; // 예시 단어
    final splitStructure = structure.split("○○"); // 문장 분리
    final spans = <InlineSpan>[];

    for (int i = 0; i < splitStructure.length; i++) {
      spans.add(TextSpan(text: splitStructure[i], style: body_small_semi(context))); // 텍스트 추가
      if (i < exampleWords.length) {
        spans.add(TextSpan(
          text: exampleWords[i], // 빈칸에 예시 단어 추가
          style: body_small_semi(context).copyWith(
            color: i == 1 ? customColors.success : customColors.primary,
          ),
        ));
      }
    }
    return spans;
  }

  // 빈칸에 대응하는 TextField 생성 메서드
  Widget _buildTextField(int index) {
    final customColors = ref.watch(customColorsProvider);
    return Flexible(
      child: Container(
        constraints: BoxConstraints(maxWidth: 100), // 입력 필드 최대 너비 설정
        child: TextField(
          controller: ref.read(controllersProvider)[index], // 해당 인덱스의 컨트롤러 연결
          decoration: InputDecoration(
            filled: true,
            fillColor: customColors.primary10, // 배경 색상
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // 테두리 둥글기
              borderSide: BorderSide.none, // 테두리 제거
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // 여백 설정
          ),
          maxLines: 1,
          onChanged: (_) => setState(() {}), // 값 변경 시 상태 갱신
        ),
      ),
    );
  }
}
