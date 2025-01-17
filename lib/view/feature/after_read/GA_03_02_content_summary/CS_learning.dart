import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../theme/theme.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/text_section.dart';
import '../widget/title_section_learning.dart';

class CSLearning extends StatefulWidget {
  const CSLearning({super.key});

  @override
  State<CSLearning> createState() => _CELearningState();
}

class _CELearningState extends State<CSLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

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
                      child: Text_Section(text: data,),
                    ),
                    SizedBox(height: 8,),
                    BigDivider(),
                    BigDivider(),
                    SizedBox(height: 8,),
                    // 사용자 입력 영역
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Answer_Section(
                        controller: _controller,
                        customColors: customColors,
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
}
