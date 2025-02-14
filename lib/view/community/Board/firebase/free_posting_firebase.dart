import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/alarm_dialog.dart';
import '../../../components/custom_app_bar.dart';
import 'community_service.dart';

class FreeWritingPage extends ConsumerStatefulWidget {
  @override
  _FreeWritingPageState createState() => _FreeWritingPageState();
}

class _FreeWritingPageState extends ConsumerState<FreeWritingPage> {
  final CommunityService _communityService = CommunityService();
  String selectedCategory = '';
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List<String> tags = [];
  Timer? _debounce;

  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleController.addListener(() => setState(() {}));
    contentController.addListener(() => setState(() {}));
    tagController.addListener(() => setState(() {}));
  }

  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  bool hasUnsavedChanges() {
    return titleController.text.isNotEmpty || contentController.text.isNotEmpty;
  }

  void addTag() {
    if (tagController.text.isNotEmpty && tags.length < 3) {
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

  Future<void> submitPost() async {
    if (!isContentValid()) return;
    try {
      await _communityService.createPost(
        title: titleController.text,
        content: contentController.text,
        category: "자유글", // 자동으로 "자유글" 설정
        tags: tags,
      );
      discardDraft();
      Navigator.of(context).pop();
    } catch (e) {
      showResultDialog(
        context,
        ref.watch(customColorsProvider),
        "게시글 작성 실패",
        "확인",
        "",
            (ctx) => Navigator.of(ctx).pop(),
      );
    }
  }


  void discardDraft() {
    setState(() {
      titleController.clear();
      contentController.clear();
      tagController.clear();
      tags.clear();
    });
  }

  void _handleClose() async {
    if (hasUnsavedChanges()) {
      showResultDialog(
        context,
        ref.watch(customColorsProvider),
        "나가시겠습니까?",
        "취소",
        "나가기",
            (ctx) {
          discardDraft();
          Navigator.of(ctx).pop();
        },
        continuationMessage: "작성 중인 내용은 저장되지 않습니다.",
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (hasUnsavedChanges()) {
      showResultDialog(
        context,
        ref.watch(customColorsProvider),
        "나가시겠습니까?",
        "취소",
        "나가기",
            (ctx) {
          discardDraft();
          Navigator.of(ctx).pop();
        },
        continuationMessage: "작성 중인 내용은 저장되지 않습니다.",
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar_2depth_9(
          title: "자유글",
          onIconPressed: _handleClose,
          actions: [
            TextButton(
              onPressed: isContentValid() ? submitPost : null,
              child: Text(
                "등록",
                style: body_xsmall_semi(context).copyWith(
                  color: isContentValid() ? customColors.primary : customColors.neutral80,
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
              WritingForm(context, customColors),
              SizedBox(height: 34),
              TagInput(context, customColors),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget TagInput(BuildContext context, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("태그 (선택)", style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  hintText: tags.length == 3 ? "태그 입력 완료" : "최대 3개의 태그를 입력해주세요 (예: 일상)",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: customColors.primary!,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: customColors.neutral80!,
                    ),
                  ),
                  hintStyle: body_small(context).copyWith(
                    color: customColors.neutral60,
                  ),
                ),
                enabled: tags.length < 3,
              ),
            ),
            ElevatedButton(
              onPressed: tagController.text.isNotEmpty && tags.length < 3 ? addTag : null,
              child: Text(
                "추가",
                style: body_xsmall_semi(context).copyWith(
                  color: tagController.text.isNotEmpty && tags.length < 3 ? customColors.primary : customColors.neutral80,
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
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: tags.map((tag) {
            return Chip(
              label: Text(tag, style: body_small(context).copyWith(color: customColors.primary)),
              backgroundColor: customColors.neutral100,
              deleteIcon: Icon(Icons.close, size: 18, color: customColors.primary),
              onDeleted: () => removeTag(tag),
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

  Widget WritingForm(BuildContext context, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          focusNode: titleFocusNode,
          decoration: InputDecoration(
            hintText: "제목을 입력하세요",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: customColors.primary!,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: customColors.neutral80!,
              ),
            ),
            hintStyle: body_medium_semi(context).copyWith(color: customColors.neutral60),
          ),
          style: body_medium_semi(context),
        ),
        SizedBox(height: 16),
        TextField(
          controller: contentController,
          focusNode: contentFocusNode,
          maxLines: 15,
          maxLength: 800,
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
    );
  }
}
