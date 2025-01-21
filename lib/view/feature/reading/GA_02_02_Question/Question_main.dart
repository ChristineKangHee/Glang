import 'package:flutter/material.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../util/box_shadow_styles.dart';
import '../../../components/custom_button.dart';
import '../../after_read/widget/answer_section.dart';

class QuestionMain extends StatefulWidget {
  @override
  _QuestionMainState createState() => _QuestionMainState();
}


class _QuestionMainState extends State<QuestionMain> {
  final TextEditingController _controller = TextEditingController();
  bool _showProblem = false; // 문제 보이기/숨기기 상태
  bool _isTextHighlighted = false; // 텍스트 색상 변경 상태
  bool _isTextFieldEmpty = true; // TextField 비어 있는 상태

  @override
  void initState() {
    super.initState();
    // TextField 값 변경 시 상태 업데이트
    _controller.addListener(() {
      setState(() {
        _isTextFieldEmpty = _controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text("텍스트 사이 문제 예시"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: reading_textstyle(context).copyWith(
                  color: customColors.neutral0,
                ),
                children: [
                  TextSpan(
                    text: '“이게 뭐지?” 코코는 머리를 갸웃거리며 열쇠를 물었어요. 열쇠는 반짝반짝 빛나며 무언가 중요한 것을 열어줄 것처럼 보였어요.',
                    style: reading_textstyle(context).copyWith(
                      color: _isTextHighlighted ? customColors.primary : customColors.neutral0,
                    ),

                  ),
                  WidgetSpan(
                    child: SizedBox(width: 4), // Space between TextSpan and WidgetSpan
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 30, // 버튼의 가로 크기
                      height: 30, // 버튼의 세로 크기
                      decoration: BoxDecoration(
                        color: customColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.star, color: customColors.secondary),
                        iconSize: 14, // 아이콘 크기 설정
                        onPressed: () {
                          setState(() {
                            _showProblem = !_showProblem;
                            _isTextHighlighted = !_isTextHighlighted;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _showProblem ? 16 : 0), // Add spacing conditionally
            AnimatedOpacity(
              opacity: _showProblem ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: _showProblem
                  ? Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6, // 화면 높이에 비례
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: ShapeDecoration(
                  color: customColors.neutral100,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: customColors.neutral90 ?? Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '핵심 내용 질문',
                      textAlign: TextAlign.center,
                      style: body_small_semi(context).copyWith(
                        color: customColors.neutral30,
                      ),

                    ),
                    SizedBox(height: 24),
                    Text(
                      '이 텍스트는 무엇을 상징할까요? 자신의 생각을 적어보세요.',
                      style: body_small_semi(context).copyWith(
                        color: customColors.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Answer_Section_No_Title(
                      controller: _controller,
                      customColors: customColors,
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: _isTextFieldEmpty
                          ? ButtonPrimary20(
                        function: () {
                          print("텍스트를 입력해주세요.");
                        },
                        title: '제출하기',
                      )
                          : ButtonPrimary(
                        function: () {
                          print("제출하기");
                          setState(() {
                            _showProblem = false;
                            _isTextHighlighted = false;
                          });
                        },
                        title: '제출하기',
                      ),
                    ),
                  ],
                ),
              )
                  : Container(),
            ),
            SizedBox(height: _showProblem ? 16 : 0), // Add spacing conditionally
            Text(
              '코코는 열쇠가 무엇을 여는지 알아내고 싶었어요. 그래서 정원을 이리저리 뛰어다니며 열쇠 구멍을 찾기 시작했어요. 그러다 커다란 나무 옆에서 작은 나무 문을 발견했어요. "여기서 열쇠를 써볼까?" 코코는 열쇠를 조심스럽게 문에 넣었어요.\n“딸깍!” 소리와 함께 문이 열렸어요. 문 뒤에는 작은 토끼가 앉아 있었어요. 토끼는 놀란 표정으로 코코를 바라보더니 웃으며 말했어요. “안녕, 코코! 이 열쇠는 내가 잃어버린 거야. 돌려줘서 고마워!”',
              style: reading_textstyle(context).copyWith(color: customColors.neutral0),
            ),
          ],
        ),
      ),
    );
  }
}
