import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'Component/taginput_component.dart';
import 'Component/writingform_component.dart';
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
      showResultSaveDialog(
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
      showResultSaveDialog(
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
      showResultSaveDialog(
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
              WritingFormComponent(
                titleController: titleController,
                contentController: contentController,
                titleFocusNode: titleFocusNode,
                contentFocusNode: contentFocusNode,
                customColors: customColors,
              ),
              const SizedBox(height: 34),
              TagInputComponent(
                tagController: tagController,
                tags: tags,
                onAddTag: addTag,
                onRemoveTag: removeTag,
                customColors: customColors,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
