import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

// TagInputComponent: 태그 입력 및 관리 컴포넌트
class TagInputComponent extends StatelessWidget {
  final TextEditingController tagController; // 태그 입력을 관리하는 컨트롤러
  final List<String> tags; // 입력된 태그 목록
  final VoidCallback onAddTag; // 태그 추가 함수
  final Function(String) onRemoveTag; // 태그 삭제 함수
  final CustomColors customColors; // 커스텀 색상

  // 생성자
  const TagInputComponent({
    Key? key,
    required this.tagController,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.customColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 태그 입력 제목
        Text(
          "태그 (선택)",
          style: body_small_semi(context).copyWith(color: customColors.neutral30),
        ),
        const SizedBox(height: 16), // 간격
        Row(
          children: [
            // 태그 입력 필드
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  // 태그 최대 개수에 따라 힌트 텍스트 변경
                  hintText: tags.length == 3
                      ? "태그 입력 완료"
                      : "최대 3개의 태그를 입력해주세요 (예: 일상)",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: customColors.primary!),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: customColors.neutral80!),
                  ),
                  hintStyle: body_small(context).copyWith(color: customColors.neutral60),
                ),
                enabled: tags.length < 3, // 태그가 3개 미만일 경우 입력 가능
              ),
            ),
            // 태그 추가 버튼
            ElevatedButton(
              onPressed: tagController.text.isNotEmpty && tags.length < 3 ? onAddTag : null,
              child: Text(
                "추가",
                style: body_xsmall_semi(context).copyWith(
                  // 버튼 색상 변경: 입력값이 있을 때만 활성화
                  color: tagController.text.isNotEmpty && tags.length < 3
                      ? customColors.primary
                      : customColors.neutral80,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                disabledBackgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12), // 간격
        // 태그 목록 표시
        Wrap(
          spacing: 8, // 태그 간 간격
          children: tags.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: body_small(context).copyWith(color: customColors.primary),
              ),
              backgroundColor: customColors.neutral100,
              deleteIcon: Icon(Icons.close, size: 18, color: customColors.primary),
              onDeleted: () => onRemoveTag(tag), // 태그 삭제 함수
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: customColors.primary!),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
