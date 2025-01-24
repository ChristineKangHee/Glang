import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_button.dart';
import '../after_read/widget/answer_section.dart';

class SubjectiveQuiz extends StatefulWidget {
  final TextEditingController controller;
  final Function() onSubmit;
  final String? initialAnswer; // 초기 답변 추가
  final bool enabled;

  const SubjectiveQuiz({
    required this.controller,
    required this.onSubmit,
    this.initialAnswer,
    required this.enabled,
  });

  @override
  _SubjectiveQuizState createState() => _SubjectiveQuizState();
}

class _SubjectiveQuizState extends State<SubjectiveQuiz> {
  bool _isTextFieldEmpty = true;
  bool _showProblem = false;
  bool _isTextHighlighted = false;
  bool _isSubmitted = false; // 답변 제출 여부를 추적

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswer != null) {
      widget.controller.text = widget.initialAnswer!; // 초기 답변 설정
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '핵심 내용 질문',
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30,
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '실시간 피드백 시스템은 학습자에게 어떤 도움을 주나요?',
                style: body_small_semi(context).copyWith(
                  color: customColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Answer_Section_No_Title에 disabled 상태 전달
            Answer_Section_No_Title(
                controller: widget.controller,
                customColors: customColors,
              ),
            const SizedBox(height: 12),
            if (!_isSubmitted) // 제출 후 버튼을 숨기기 위해 조건 추가
              Container(
                width: MediaQuery.of(context).size.width,
                child: _isTextFieldEmpty
                    ? ButtonPrimary20_noPadding(
                  function: () {
                    print("텍스트를 입력해주세요.");
                  },
                  title: '제출하기',
                )
                    : ButtonPrimary_noPadding(
                  function: () {
                    setState(() {
                      _showProblem = false;
                      _isTextHighlighted = false;
                      _isSubmitted = true; // 제출 상태로 변경
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
