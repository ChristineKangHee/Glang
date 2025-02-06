import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class CommunityPostPage extends ConsumerStatefulWidget {
  @override
  _CommunityPostPageState createState() => _CommunityPostPageState();
}

class _CommunityPostPageState extends ConsumerState<CommunityPostPage> {
  String selectedCategory = ''; // No default selection
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List<String> tags = [];

  // Define FocusNode
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add a listener to the tagController to track text changes
    tagController.addListener(() {
      setState(() {}); // Trigger UI update when text changes
    });
  }

  // Function to check if both title and content are filled
  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  void addTag() {
    if (tagController.text.isNotEmpty) {
      setState(() {
        tags.add(tagController.text);
        tagController.clear();
      });
    }
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  void saveDraft() {
    print("임시 저장됨: 제목=${titleController.text}, 내용=${contentController.text}");
  }

  void submitPost() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("제목과 내용을 입력해주세요."),
      ));
      return;
    }
    print("게시글 등록됨: 제목=${titleController.text}, 내용=${contentController.text}, 태그=$tags");
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    tagController.dispose(); // Dispose the tagController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_9(
        title: "글쓰기",
        actions: [
          TextButton(
            onPressed: saveDraft,
            child: Text(
              "임시저장",
              style: body_xsmall_semi(context).copyWith(
                color: isContentValid()
                    ? customColors.primary
                    : customColors.neutral80,
              ),
            ),
          ),
          TextButton(
            onPressed: submitPost,
            child: Text(
              "등록",
              style: body_xsmall_semi(context).copyWith(
                color: isContentValid()
                    ? customColors.primary
                    : customColors.neutral80,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("게시판 선택", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
            SizedBox(height: 16),
            Row(
              children: [
                buildCategoryButton('코스', customColors),
                SizedBox(width: 8),
                buildCategoryButton('인사이트', customColors),
                SizedBox(width: 8),
                buildCategoryButton('에세이', customColors),
              ],
            ),
            SizedBox(height: 34),

            Text("글 작성", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: customColors.neutral80!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    decoration: InputDecoration(
                      hintText: "제목을 입력하세요",
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: titleFocusNode.hasFocus
                              ? customColors.primary!
                              : customColors.neutral80!,
                        ),
                      ),
                      hintStyle: body_medium_semi(context).copyWith(
                        color: customColors.neutral60,
                      ),
                    ),
                    style: body_medium_semi(context),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    focusNode: contentFocusNode,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "내용을 입력해주세요.\n1. 타인에게 불쾌감을 주지 않는 내용\n2. 개인정보 보호 규정 준수\n3. 욕설 및 비하 발언 금지",
                      hintStyle: body_small(context).copyWith(
                        color: customColors.neutral60,
                      ),
                      border: InputBorder.none,
                    ),
                    style: body_small(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 34),

            Text("태그 (선택)", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    decoration: InputDecoration(
                      hintText: "태그를 입력해주세요 (예: 일상)",
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: titleFocusNode.hasFocus
                              ? customColors.primary!
                              : customColors.neutral80!,
                        ),
                      ),
                      hintStyle: body_small(context).copyWith(
                        color: customColors.neutral60,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: addTag,
                  child: Text(
                    "추가",
                    style: body_xsmall_semi(context).copyWith(
                      color: tagController.text.isNotEmpty
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: body_small(context).copyWith(
                      color: customColors.primary, // Text color as primary
                    ),
                  ),
                  backgroundColor: customColors.neutral100, // Background color for the chip
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18, // Size of the delete icon
                    color: customColors.primary, // Color of the delete icon
                  ),
                  onDeleted: () => removeTag(tag),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for the chip
                    side: BorderSide(color: customColors.primary!), // Set the border color to primary
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryButton(String category, CustomColors customColors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: selectedCategory == category ? customColors.primary : customColors.neutral100,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: selectedCategory == category ? Colors.transparent : customColors.neutral80!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
            category,
            style: body_xsmall_semi(context).copyWith(color: selectedCategory == category ? customColors.neutral100 : customColors.neutral60)
        ),
      ),
    );
  }
}
