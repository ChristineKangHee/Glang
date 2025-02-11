/// File: answer_section_BR.dart
/// Purpose: 사용자의 답변(제목 및 내용) 입력 필드를 제공하는 위젯
/// Author: 박민준
/// Created: 2025-01-0?
/// Last Modified: 2025-02-05 by 박민준

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import '../../../../../theme/theme.dart';

class AnswerSectionBr extends StatefulWidget {
  const AnswerSectionBr({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.customColors,
    this.maxLength = 50, // 기본 최대 글자 수
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final CustomColors customColors;
  final int maxLength;

  @override
  _AnswerSectionState createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSectionBr> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    widget.contentController.addListener(_updateCurrentLength);
  }

  @override
  void dispose() {
    widget.contentController.removeListener(_updateCurrentLength);
    super.dispose();
  }

  void _updateCurrentLength() {
    setState(() {
      _currentLength = widget.contentController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("나의 답변: 제목", style: body_small(context)),
        const SizedBox(height: 16),
        SizedBox(
          child: TextField(
            controller: widget.titleController,
            maxLines: 1,
            style: body_medium(context),
            decoration: InputDecoration(
              hintText: "제목을 작성해주세요.",
              hintStyle: body_medium(context).copyWith(color: widget.customColors.neutral60),
              filled: true,
              fillColor: widget.customColors.neutral90,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("나의 답변: 내용", style: body_small(context)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: TextField(
            controller: widget.contentController,
            maxLength: widget.maxLength,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: body_medium(context),
            decoration: InputDecoration(
              hintText: "내용을 작성해주세요.",
              hintStyle: body_medium(context).copyWith(color: widget.customColors.neutral60),
              filled: true,
              fillColor: widget.customColors.neutral90,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              counterText: "$_currentLength/${widget.maxLength}",
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
