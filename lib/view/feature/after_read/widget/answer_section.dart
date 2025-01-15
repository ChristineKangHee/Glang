import 'package:flutter/material.dart';

import '../../../../../theme/font.dart';
import '../../../../../theme/theme.dart';

class Answer_Section extends StatelessWidget {
  const Answer_Section({
    super.key,
    required TextEditingController controller,
    required this.customColors,
  }) : _controller = controller;

  final TextEditingController _controller;
  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("나의 답변", style: body_small(context)),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100, // 최소 높이
            maxHeight: 300, // 최대 높이
          ),
          child: TextField(
            controller: _controller,
            maxLines: null, // 자동으로 줄 수를 조정
            expands: false, // `maxLines`와 함께 사용하지 않음
            style: body_medium(context),
            decoration: InputDecoration(
              hintText: "글을 작성해주세요.",
              hintStyle:
              body_medium(context).copyWith(color: customColors.neutral60),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}