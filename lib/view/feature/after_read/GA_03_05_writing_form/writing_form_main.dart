import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/font.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import 'package:readventure/theme/theme.dart';

import '../../../components/my_divider.dart';

final controllersProvider = Provider<Map<int, TextEditingController>>((ref) {
  // Create and manage controllers for the fields
  final controllers = <int, TextEditingController>{};
  for (int i = 0; i < 4; i++) {
    controllers[i] = TextEditingController();
  }
  return controllers;
});

class SentencePractice extends ConsumerStatefulWidget {
  @override
  _SentencePracticeState createState() => _SentencePracticeState();
}

class _SentencePracticeState extends ConsumerState<SentencePractice> {
  final String structure = "○○는 □□에서 가장 ○○한 인물이다";

  @override
  void dispose() {
    // Dispose controllers when widget is disposed
    final controllers = ref.read(controllersProvider);
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Check if all TextFields are filled
  bool _areFieldsFilled() {
    final controllers = ref.read(controllersProvider);
    return controllers.values.every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final controllers = ref.watch(controllersProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_8(title: '문장 구조 연습',),
      body: Column(
          children: [
            ExampleForm(context, customColors),
            // 저장 및 초기화 버튼
            SizedBox(height: 24),
            BigDivider(),
            SizedBox(height: 24),
            // 문장 형식과 빈칸 미리보기
            MyAnswer(context),
            // 문장의 예시와 빈칸 채우기 안내
            SizedBox(height: 24),

            // Spacer to push the submit button to the bottom
            Spacer(),
            // 제출하기 버튼 추가
            SubmitButton(context),
            SizedBox(height: 24),
          ],
        ),
    );
  }

  Container MyAnswer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft, // 전체 컨테이너 내용 왼쪽 정렬
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 내부 요소 왼쪽 정렬
              children: [
                Text(
                  "나의 답변",
                  style: body_medium_semi(context),
                  textAlign: TextAlign.start, // 텍스트 왼쪽 정렬
                ),
                SizedBox(height: 8), // 텍스트와 Wrap 사이 간격
                Wrap(
                  spacing: 12, // 요소 간 가로 간격
                  runSpacing: 8, // 요소 간 세로 간격
                  children: [
                    _buildTextField(0),
                    Text("은(는)", style: body_small(context)),
                    _buildTextField(1),
                    Text("에서 가장", style: body_small(context)),
                    _buildTextField(2),
                    Text("한", style: body_small(context)),
                    _buildTextField(3),
                    Text("이다", style: body_small(context)),
                  ],
                ),
              ],
            ),
          );
  }

  Container SubmitButton(BuildContext context) {
    return Container(
            width: MediaQuery.of(context).size.width,
            child: _areFieldsFilled()
                ? ButtonPrimary(
              function: () {
                print("제출하기");
                // function은 상황에 맞게 재정의 할 것.
              },
              title: '제출하기',
            )
                : ButtonPrimary20(
              function: () {
                print("제출하기");
                // function은 상황에 맞게 재정의 할 것.
              },
              title: '제출하기',
            ),
          );
  }

  Container ExampleForm(BuildContext context, CustomColors customColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(

              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
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
                      Container(
                        child: Column(
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
                                  children: [
                                    TextSpan(
                                      text: '아인슈타인',
                                      style: body_small_semi(context),
                                    ),
                                    TextSpan(
                                      text: '은 ',
                                      style: body_small_semi(context),
                                    ),
                                    TextSpan(
                                      text: '물리학',
                                      style: body_small_semi(context).copyWith(color: customColors.success),
                                    ),
                                    TextSpan(
                                      text: '에서 가장 ',
                                      style: body_small_semi(context),
                                    ),
                                    TextSpan(
                                      text: '영향력 있는',
                                      style: body_small_semi(context).copyWith(color: customColors.primary),
                                    ),
                                    TextSpan(
                                      text: ' 인물이다',
                                      style: body_small_semi(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTextField(int index) {
    final customColors = ref.watch(customColorsProvider);
    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 100, // Set maximum width to prevent it from growing indefinitely
        ),
        child: TextField(
          controller: ref.read(controllersProvider)[index],
          decoration: InputDecoration(
            filled: true,
            fillColor: customColors.primary10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // 테두리 없애기
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          maxLines: 1,
          minLines: 1,
          expands: false,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }
}
