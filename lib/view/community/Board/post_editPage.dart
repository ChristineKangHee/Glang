/// File: post_editPage.dart
/// Purpose: 게시글 수정 화면을 담당하는 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

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
import 'community_data_firebase.dart'; // Post 모델이 정의되어 있다고 가정

/// 게시글 수정 화면을 담당하는 위젯
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

  /// 제목과 내용이 비어있지 않으면 유효한 내용으로 판단
  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  /// 저장되지 않은 변경사항이 있는지 확인
  bool hasUnsavedChanges() {
    return titleController.text != widget.post.title ||
        contentController.text != widget.post.content ||
        tags.toString() != widget.post.tags.toString();
  }

  /// 태그 추가 함수
  void addTag() {
    if (tagController.text.isNotEmpty && tags.length < 3) {
      setState(() {
        tags.add(tagController.text);
        tagController.clear();
      });
    }
  }

  /// 태그 제거 함수
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  /// 게시글 수정 후 저장하는 함수
  Future<void> submitEdit() async {
    if (!isContentValid()) return;
    try {
      // 수정된 게시글 정보 서버에 업데이트
      await _communityService.updatePost(
        postId: widget.post.id,
        title: titleController.text,
        content: contentController.text,
        tags: tags,
      );
      Navigator.of(context).pop(); // 수정 후 이전 화면으로 돌아감
    } catch (e) {
      // 수정 실패 시 알림 대화상자 표시
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

  /// 뒤로 가기 전에 변경사항 확인
  Future<bool> _onWillPop() async {
    if (hasUnsavedChanges()) {
      // 변경사항이 있을 경우 취소 또는 나가기 옵션을 선택할 수 있는 대화상자 표시
      showResultSaveDialog(
        context,
        ref.watch(customColorsProvider),
        "나가시겠습니까?",
        "취소",
        "나가기",
            (ctx) {
          discardChanges(); // 변경사항 취소
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
    // 위젯이 폐기될 때 리소스를 정리
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
      onWillPop: _onWillPop, // 뒤로 가기 전에 변경사항 확인
      child: Scaffold(
        appBar: CustomAppBar_2depth_9(
          title: "게시글 수정", // 앱 바 제목 설정
          onIconPressed: () async {
            if (await _onWillPop()) Navigator.of(context).pop();
          },
          actions: [
            // 수정 버튼: 내용이 유효한 경우만 활성화
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
              // 게시글 제목, 내용 입력 필드
              WritingFormComponent(
                titleController: titleController,
                contentController: contentController,
                titleFocusNode: titleFocusNode,
                contentFocusNode: contentFocusNode,
                customColors: customColors,
              ),
              const SizedBox(height: 34),
              // 태그 입력 및 추가 컴포넌트
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
