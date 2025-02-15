import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/alarm_dialog.dart';
import '../../../components/custom_app_bar.dart';
import '../Component/taginput_component.dart';
import '../Component/writingform_component.dart';
import 'community_service.dart';
import 'community_data_firebase.dart'; // Post 모델이 정의되어 있다고 가정

class PostEditPage extends ConsumerStatefulWidget {
  final Post post;
  const PostEditPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostEditPageState createState() => _PostEditPageState();
}

class _PostEditPageState extends ConsumerState<PostEditPage> {
  final CommunityService _communityService = CommunityService();
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController tagController;
  List<String> tags = [];
  Timer? _debounce;

  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 기존 게시글 데이터를 미리 불러오기
    titleController = TextEditingController(text: widget.post.title);
    contentController = TextEditingController(text: widget.post.content);
    tagController = TextEditingController();
    tags = List<String>.from(widget.post.tags);

    titleController.addListener(() => setState(() {}));
    contentController.addListener(() => setState(() {}));
    tagController.addListener(() => setState(() {}));
  }

  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  /// 저장되지 않은 변경사항이 있는지 확인
  bool hasUnsavedChanges() {
    return titleController.text != widget.post.title ||
        contentController.text != widget.post.content ||
        tags.toString() != widget.post.tags.toString();
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

  Future<void> submitEdit() async {
    if (!isContentValid()) return;
    try {
      await _communityService.updatePost(
        postId: widget.post.id,
        title: titleController.text,
        content: contentController.text,
        tags: tags,
      );
      Navigator.of(context).pop(); // 수정 후 이전 화면으로 돌아감
    } catch (e) {
      showResultSaveDialog(
        context,
        ref.watch(customColorsProvider),
        "게시글 수정 실패",
        "확인",
        "",
            (ctx) => Navigator.of(ctx).pop(),
      );
    }
  }

  /// 변경사항 취소: 기존 게시글 데이터로 되돌림
  void discardChanges() {
    setState(() {
      titleController.text = widget.post.title;
      contentController.text = widget.post.content;
      tags = List<String>.from(widget.post.tags);
      tagController.clear();
    });
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
          discardChanges();
          Navigator.of(ctx).pop();
        },
        continuationMessage: "작성 중인 내용은 저장되지 않습니다.",
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar_2depth_9(
          title: "게시글 수정",
          onIconPressed: () async {
            if (await _onWillPop()) Navigator.of(context).pop();
          },
          actions: [
            TextButton(
              onPressed: isContentValid() ? submitEdit : null,
              child: Text(
                "수정",
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
