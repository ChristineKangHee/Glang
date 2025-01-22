import 'package:flutter/material.dart';
import 'package:readventure/viewmodel/custom_colors_provider.dart';
import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';

class Answer_Section extends StatefulWidget {
  const Answer_Section({
    super.key,
    required this.controller,
    required this.customColors,
    this.maxLength = 200, // 기본 최대 글자 수
  });

  final TextEditingController controller;
  final CustomColors customColors;
  final int maxLength;

  @override
  _AnswerSectionState createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<Answer_Section> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCurrentLength);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCurrentLength);
    super.dispose();
  }

  void _updateCurrentLength() {
    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("나의 답변", style: body_small(context)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: TextField(
            controller: widget.controller,
            maxLength: widget.maxLength, // 최대 글자 수 설정
            maxLines: null, // 자동으로 줄 수를 조정
            expands: true, // `maxLines`와 함께 사용하지 않음
            textAlignVertical: TextAlignVertical.top,
            style: body_medium(context),
            decoration: InputDecoration(
              hintText: "글을 작성해주세요.",
              hintStyle: body_medium(context)
                  .copyWith(color: widget.customColors.neutral60),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              counterText: "$_currentLength/${widget.maxLength}", // 현재 글자 수 / 최대 글자 수
              counterStyle: body_small(context).copyWith(color: widget.customColors.neutral60),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Answer_Section_No_Title extends StatefulWidget {
  const Answer_Section_No_Title({
    super.key,
    required this.controller,
    required this.customColors,
    this.maxLength = 200, // 기본 최대 글자 수
    required this.enabled, // TextField 활성화 여부
  });

  final TextEditingController controller;
  final CustomColors customColors;
  final int maxLength;
  final bool enabled; // TextField 활성화 여부

  @override
  _AnswerSectionNoTitleState createState() => _AnswerSectionNoTitleState();
}

class _AnswerSectionNoTitleState extends State<Answer_Section_No_Title> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCurrentLength);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCurrentLength);
    super.dispose();
  }

  void _updateCurrentLength() {
    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled, // 활성화 여부를 외부에서 설정
            maxLength: widget.maxLength, // 최대 글자 수 설정
            maxLines: null, // 자동으로 줄 수를 조정
            expands: true, // `maxLines`와 함께 사용하지 않음
            textAlignVertical: TextAlignVertical.top,
            style: body_medium(context),
            decoration: InputDecoration(
              hintText: "글을 작성해주세요.",
              hintStyle: body_medium(context)
                  .copyWith(color: widget.customColors.neutral60),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              counterText: "$_currentLength/${widget.maxLength}", // 현재 글자 수 / 최대 글자 수
              counterStyle: body_small(context).copyWith(color: widget.customColors.neutral60),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}