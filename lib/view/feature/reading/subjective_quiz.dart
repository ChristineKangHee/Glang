import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_button.dart';
import '../after_read/widget/answer_section.dart';

class SubjectiveQuiz extends StatefulWidget {
  final TextEditingController controller;
  final Function() onSubmit;

  const SubjectiveQuiz({required this.controller, required this.onSubmit});

  @override
  _SubjectiveQuizState createState() => _SubjectiveQuizState();
}

class _SubjectiveQuizState extends State<SubjectiveQuiz> {
  bool _isTextFieldEmpty = true;
  bool _showProblem = false;
  bool _isTextHighlighted = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldEmpty = widget.controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2, color: customColors.neutral90 ?? Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              '코코가 발견한 황금 열쇠에 대해 어떻게 생각하나요? 자신의 의견을 작성해보세요.',
              style: body_small_semi(context).copyWith(
                color: customColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            // Use your Answer_Section_No_Title component here
            Answer_Section_No_Title(
              controller: widget.controller,
              customColors: customColors,
            ),
            const SizedBox(height: 12),
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
                  widget.onSubmit();
                },
                title: '제출하기',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
}
