import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../theme/theme.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/text_section.dart';
import '../widget/title_section_learning.dart';

class WELearning extends StatefulWidget {
  const WELearning({super.key});

  @override
  State<WELearning> createState() => _CELearningState();
}

class _CELearningState extends State<WELearning> {
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
    final data = "깊은 숲 속 작은 오두막에 살던 토끼 가족 중 가장 작은 토끼가 숲에서 길을 잃었어요. 작은 토끼는 용기를 내어 큰 나무 옆에 있던 다람쥐에게 도움을 요청했고, 다람쥐의 도움으로 무사히 집으로 돌아갈 수 있었답니다.";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "에세이 작성"),
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
                      child: TitleSection_withIcon(
                        customColors: Theme.of(context).extension<CustomColors>()!, // CustomColors 가져오기
                        title: "자신의 경험과 의견을 작성해 주세요!",               // 제목
                        subtitle: "<토끼 가족 이야기 중>",                           // 부제목
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
