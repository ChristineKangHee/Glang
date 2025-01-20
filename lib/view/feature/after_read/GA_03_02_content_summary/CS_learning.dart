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

class CSLearning extends StatefulWidget {
  const CSLearning({super.key});

  @override
  State<CSLearning> createState() => _CELearningState();
}

class _CELearningState extends State<CSLearning> {
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
    final data= "깊은 숲 속 작은 오두막에는 토끼 가족이 살고 있었어요. 어느 날, 토끼 엄마는 아기 토끼들에게 말했어요. ‘오늘은 숲 속에 숨어 있는 가장 달콤한 당근을 찾아보자.’ 아기 토끼들은 신이 나서 숲으로 달려갔어요. 그런데, 가장 작은 토끼가 길을 잃고 말았답니다. 작은 토끼는 용기를 내어 큰 나무 옆에 숨은 다람쥐에게 도움을 요청했어요. 작은 토끼는 용기를 내어 큰 나무 옆에 숨은 다람쥐에게 도움을 요청했어요.깊은 숲 속 작은 오두막에는 토끼 가족이 살고 있었어요. 어느 날, 토끼 엄마는 아기 토끼들에게 말했어요. ‘오늘은 숲 속에 숨어 있는 가장 달콤한 당근을 찾아보자.’ 아기 토끼들은 신이 나서 숲으로 달려갔어요. 그런데, 가장 작은 토끼가 길을 잃고 말았답니다. 작은 토끼는 용기를 내어 큰 나무 옆에 숨은 다람쥐에게 도움을 요청했어요. 작은 토끼는 용기를 내어 큰 나무 옆에 숨은 다람쥐에게 도움을 요청했어요.";

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
          backgroundColor: Colors.yellow,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.emoji_objects_outlined,
            color: Colors.black,
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
                        subtitle: "<토끼 가족 이야기>",                           // 부제목
                        author: "김댕댕",                                         // 작성자                         // 아이콘 (기본값: Icons.import_contacts)
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
                                    : null
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
                                      : null
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "맥락에 맞는 글",
                                      style: body_small_semi(context).copyWith(color: customColors.neutral30),
                                    ),
                                    Text(
                                      "자동 추가",
                                      style: body_small_semi(context).copyWith(color: customColors.neutral30),
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
                    // 선택 완료 버튼
                    ButtonPrimary_noPadding(
                      function: () {
                        Navigator.of(context).pop();
                        if (selectedOption == 1) {
                          // 첫 번째 옵션 동작
                          print("키워드 3개 선택");
                          _updateKeywords(["#키워드1", "#키워드2", "#키워드3"]); // 키워드 업데이트
                        } else if (selectedOption == 2) {
                          // 두 번째 옵션 동작
                          print("맥락에 맞는 글 자동 추가 선택");
                          _updateTextField("자동 추가된 단어"); // 텍스트 필드에 단어 추가
                        }
                      },
                      title: '선택 완료',
                      condition: selectedOption != null ? "not null" : "null", // 선택된 옵션에 따라 상태 결정
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
