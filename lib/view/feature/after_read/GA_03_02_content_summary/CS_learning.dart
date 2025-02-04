import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../theme/theme.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/custom_chip.dart';
import '../widget/text_section.dart';
import '../widget/title_section_learning.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'CS_main.dart';

class CSLearning extends StatefulWidget {
  const CSLearning({super.key});

  @override
  State<CSLearning> createState() => _CSLearningState();
}

class _CSLearningState extends State<CSLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  // 키워드 상태 추가
  List<String> _keywords = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  // 결과창 띄우기
  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog();
      },
    );
  }

  // 텍스트 필드에 단어 추가
  void _updateTextField(String newWord) {
    setState(() {
      final currentText = _controller.text;
      _controller.text = currentText.isEmpty
          ? newWord
          : '$currentText $newWord'; // 기존 텍스트에 단어 추가
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length), // 커서를 맨 끝으로 이동
      );
    });
  }

  // 키워드 업데이트 함수
  void _updateKeywords(List<String> keywords) {
    setState(() {
      _keywords = keywords;
    });
  }


  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final data= "현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다. 기존의 교육 시스템은 주로 일률적인 교재와 평가 방식을 사용하며, 이는 학습 동기를 저하시킬 위험이 있다. 또한, 읽기 과정에서 즉각적인 피드백을 제공하는 시스템이 부족하여 학습자는 자신의 약점이나 강점을 파악하기 어렵다. 맞춤형 읽기 도구와 실시간 피드백 시스템은 학습자가 적합한 자료를 통해 능동적으로 읽기 능력을 향상시키고, 스스로 학습 과정을 조율할 수 있는 환경을 제공할 잠재력이 있다. 또한, 맞춤형 읽기 도구는 학습자의 수준과 흥미를 고려하여 적합한 자료를 제공할 수 있다. 이러한 도구의 개발과 보급은 개인화된 학습의 미래를 열어갈 중요한 과제가 될 것이다.";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ContentSummaryMain();
        },
      );
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "내용 요약 게임"),
      // floatingActionButtonLocation: ,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70), // 하단에서 50px 위로 이동
        child: FloatingActionButton(
          onPressed: () {
            // 버튼 동작
            _showHintDialog();
          },
          backgroundColor: customColors.secondary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.emoji_objects_outlined,
            color: customColors.neutral100,
            size: 28,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이머와 제목 섹션
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TitleSection_withoutIcon(
                        customColors: Theme.of(context).extension<CustomColors>()!, // CustomColors 가져오기
                        title: "글을 3문장으로 요약해주세요!",               // 제목
                        subtitle: "개인의 수준과 흥미를 고려한 읽기 도구의 필요성",                           // 부제목
                        author: "AI",                                     // 작성자                         // 아이콘 (기본값: Icons.import_contacts)
                      ),
                    ),
                    // 본문 텍스트
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 200,
                          child:SingleChildScrollView(
                            child: Text_Section(
                              text: data,
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 8,),
                    BigDivider(),
                    BigDivider(),
                    SizedBox(height: 8,),
                    // 사용자 입력 영역
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16,16,16,0),
                      child: Answer_Section(
                        controller: _controller,
                        customColors: customColors,
                      ),
                    ),
                    if (_keywords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _keywords
                              .map(
                                (keyword) => CustomChip(
                              label: keyword,
                              customColors: customColors, // CustomColors를 전달
                              borderRadius: 14.0, // 원하는 Radius 값 설정 가능
                            ),
                          )
                              .toList(),
                        ),
                      ),

                  ],
                ),
              ),
            ),
            // 제출 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildButton(customColors),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildButton(CustomColors customColors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isButtonEnabled ? _showAlertDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          disabledBackgroundColor: customColors.primary20,
          disabledForegroundColor: Colors.white,
        ),
        child: const Text("제출하기", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showHintDialog() {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    int? selectedOption; // 선택된 옵션을 저장

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "힌트 2가지 중 하나를 선택해주세요",
                          style: body_large_semi(context).copyWith(color: customColors.neutral30),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        // 첫 번째 버튼
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () {
                              setState(() {
                                selectedOption = 1; // 첫 번째 버튼 선택
                              });
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 1
                                    ? customColors.primary10 // 선택된 경우 색상 변경
                                    : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 1
                                    ? Border.all(color: customColors.primary ?? Colors.blue) // 선택된 경우 색상 변경
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "키워드 3개",
                                  style: body_small_semi(context).copyWith(color: customColors.neutral30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // 두 번째 버튼
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () {
                              setState(() {
                                selectedOption = 2; // 두 번째 버튼 선택
                              });
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 2
                                    ? customColors.primary10 // 선택된 경우 색상 변경
                                    : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 2
                                    ? Border.all(color: customColors.primary ?? Colors.blue) // 선택된 경우 색상 변경
                                    : null,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "맥락에 맞는 글\n자동 추가",
                                      style: body_small_semi(context).copyWith(color: customColors.neutral30),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 선택 완료 버튼 - 상태에 따라 다른 버튼 사용
                    selectedOption == null
                        ? ButtonPrimary20_noPadding(
                      function: () {}, // 선택 전이므로 동작 없음
                      title: '선택 완료',
                      condition: "null",
                    )
                        : ButtonPrimary_noPadding(
                      function: () {
                        Navigator.of(context).pop();
                        if (selectedOption == 1) {
                          print("키워드 3개 선택");
                          _updateKeywords(["#읽기 능력", "#맞춤형 도구", "#피드백"]); // 키워드 업데이트
                        } else if (selectedOption == 2) {
                          print("맥락에 맞는 글 자동 추가 선택");
                          _updateTextField("추후 AI가 자동 생성합니다!"); // 텍스트 필드에 단어 추가
                        }
                      },
                      title: '선택 완료',
                      condition: "not null",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }




}
