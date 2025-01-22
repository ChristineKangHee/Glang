import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../theme/theme.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/text_section.dart';
import '../widget/title_section_learning.dart';

class FCLearning extends StatefulWidget {
  const FCLearning({super.key});

  @override
  State<FCLearning> createState() => _CELearningState();
}

class _CELearningState extends State<FCLearning> {
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
    final data = "최근 맞춤형 읽기 도구와 실시간 피드백 시스템이 주목받고 있다. 기존 교육 시스템의 일률적인 방식이 학습 동기를 저하시킬 수 있다는 지적이 이어지면서, 학습자의 수준과 흥미를 고려한 개인화된 도구의 필요성이 대두되고 있다. 전문가들은 “이러한 도구가 학습 효율을 극대화하며, 미래의 교육 방향을 혁신적으로 바꿀 가능성이 있다”고 전망했다.";
    final provide_format = "본문에서 세 문장을 선택해 흥미로운 뉴스 기사를 작성하세요.";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "형식 변환 연습"),
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
                        title: "아래 글의 형식을 변환 시켜주세요!",               // 제목
                        subtitle: "개인의 수준과 흥미를 고려한 읽기 도구의 필요성",                           // 부제목
                        author: "AI",                                          // 작성자                         // 아이콘 (기본값: Icons.import_contacts)
                      ),
                    ),
                    // 본문 텍스트
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16,16,16,24),
                      child: Text_Section(text: data,),
                    ),
                    BigDivider(),
                    BigDivider(),
                    // 사용자 입력 영역
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16,24,16,0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: customColors.primary10,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(provide_format, style: body_small(context),),
                        ),
                      ),
                    ),
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
