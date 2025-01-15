import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../theme/theme.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/text_section.dart';
import '../widget/title_section_recycle.dart';

class CELearning extends StatefulWidget {
  const CELearning({super.key});

  @override
  State<CELearning> createState() => _CELearningState();
}

class _CELearningState extends State<CELearning> {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "결말바꾸기"),
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
                        title: "글을 읽고 나만의 결말을 작성해보세요!",               // 제목
                        subtitle: "<토끼 가족 이야기>",                           // 부제목
                        author: "김댕댕",                                         // 작성자                         // 아이콘 (기본값: Icons.import_contacts)
                      ),
                    ),
                    // 본문 텍스트
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text_Section(),
                    ),
                    BigDivider(),
                    BigDivider(),
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
            borderRadius: BorderRadius.circular(8.0),
          ),
          disabledBackgroundColor: customColors.primary20,
          disabledForegroundColor: Colors.white,
        ),
        child: const Text("제출하기", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
