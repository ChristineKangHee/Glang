/// File: keyword_selection.dart
/// Purpose: WritingFormComponent 위젯은 글 제목과 내용을 입력받는 폼을 구성한다.
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

/// WritingFormComponent 위젯은 글 제목과 내용을 입력받는 폼을 구성한다.
/// 제목은 선택된 키워드가 있으면 표시되고, 내용은 여러 줄 입력을 받을 수 있다.
class WritingFormComponent extends StatelessWidget {
  final TextEditingController titleController; // 제목 입력을 위한 컨트롤러
  final TextEditingController contentController; // 내용 입력을 위한 컨트롤러
  final FocusNode titleFocusNode; // 제목 입력 포커스를 관리하는 FocusNode
  final FocusNode contentFocusNode; // 내용 입력 포커스를 관리하는 FocusNode
  final CustomColors customColors; // 앱의 테마 색상
  final String? selectedKeyword; // 선택된 키워드 (EssayPage에서 전달됨)

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
        // 선택된 키워드가 있으면 제목 앞에 키워드를 표시
        if (selectedKeyword != null && selectedKeyword!.isNotEmpty)
          Row(
            children: [
              Text(
                "[$selectedKeyword]", // 선택된 키워드를 표시
                style: body_medium_semi(context).copyWith(color: customColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  maxLength: 100,
                  controller: titleController, // 제목 입력을 위한 컨트롤러
                  focusNode: titleFocusNode, // 제목 입력 포커스를 관리하는 FocusNode
                  decoration: InputDecoration(
                    hintText: "제목을 입력하세요", // 제목 힌트 텍스트
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
        // 선택된 키워드가 없으면 제목 입력 필드만 표시
          TextField(
            controller: titleController, // 제목 입력을 위한 컨트롤러
            focusNode: titleFocusNode, // 제목 입력 포커스를 관리하는 FocusNode
            decoration: InputDecoration(
              hintText: "제목을 입력하세요", // 제목 힌트 텍스트
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
        const SizedBox(height: 16), // 제목과 내용 사이의 간격
        TextField(
          controller: contentController, // 내용 입력을 위한 컨트롤러
          focusNode: contentFocusNode, // 내용 입력 포커스를 관리하는 FocusNode
          maxLines: 15, // 최대 15줄 입력
          maxLength: 800, // 최대 800자 입력
          decoration: InputDecoration(
            hintText:
            "내용을 입력해주세요.\n1. 타인에게 불쾌감을 주지 않는 내용\n2. 개인정보 보호 규정 준수\n3. 욕설 및 비하 발언 금지", // 내용 힌트 텍스트
            hintStyle: body_small(context).copyWith(color: customColors.neutral60),
            border: InputBorder.none, // 테두리 없음
          ),
          style: body_small(context),
        ),
      ],
    );
  }
}
