import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

class WritingFormComponent extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final FocusNode titleFocusNode;
  final FocusNode contentFocusNode;
  final CustomColors customColors;
  final String? selectedKeyword; // EssayPage에서는 선택된 키워드 전달

  const WritingFormComponent({
    Key? key,
    required this.titleController,
    required this.contentController,
    required this.titleFocusNode,
    required this.contentFocusNode,
    required this.customColors,
    this.selectedKeyword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Essay의 경우 선택된 키워드가 있으면 앞에 표시
        if (selectedKeyword != null && selectedKeyword!.isNotEmpty)
          Row(
            children: [
              Text(
                "[$selectedKeyword]",
                style: body_medium_semi(context).copyWith(color: customColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: titleController,
                  focusNode: titleFocusNode,
                  decoration: InputDecoration(
                    hintText: "제목을 입력하세요",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: customColors.primary!),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: customColors.neutral80!),
                    ),
                    hintStyle: body_medium_semi(context)
                        .copyWith(color: customColors.neutral60),
                  ),
                  style: body_medium_semi(context),
                ),
              ),
            ],
          )
        else
          TextField(
            controller: titleController,
            focusNode: titleFocusNode,
            decoration: InputDecoration(
              hintText: "제목을 입력하세요",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: customColors.primary!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: customColors.neutral80!),
              ),
              hintStyle: body_medium_semi(context)
                  .copyWith(color: customColors.neutral60),
            ),
            style: body_medium_semi(context),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: contentController,
          focusNode: contentFocusNode,
          maxLines: 15,
          maxLength: 800,
          decoration: InputDecoration(
            hintText:
            "내용을 입력해주세요.\n1. 타인에게 불쾌감을 주지 않는 내용\n2. 개인정보 보호 규정 준수\n3. 욕설 및 비하 발언 금지",
            hintStyle: body_small(context).copyWith(color: customColors.neutral60),
            border: InputBorder.none,
          ),
          style: body_small(context),
        ),
      ],
    );
  }
}
