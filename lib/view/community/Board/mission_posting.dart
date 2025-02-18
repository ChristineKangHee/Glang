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
import 'missionBottomsheet.dart';

class MissionPostPage extends ConsumerStatefulWidget {
  @override
  _MissionPostPageState createState() => _MissionPostPageState();
}

class _MissionPostPageState extends ConsumerState<MissionPostPage> {
  String selectedCourse = '';
  String selectedStage = '';
  String selectedMission = '';
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List<String> tags = [];
  Timer? _debounce;
  int currentIndex = 0;

  // FocusNode
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 페이지 로드 후 자동으로 바텀시트 표시
    WidgetsBinding.instance.addPostFrameCallback((_) => showCourseSelectionSheet(context));

    void onTextChanged() {
      setState(() {});
    }

    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
    tagController.addListener(() => setState(() {}));
  }

  // 바텀시트로부터 미션 선택
  void showCourseSelectionSheet(BuildContext context) async {
    final selectedMission = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CourseSelectionBottomSheet(),
    );

    if (selectedMission != null) {
      setState(() {
        this.selectedMission = selectedMission;
        // 제목에 selectedMission을 넣지 않고, selectedKeyword로만 전달합니다.
        // titleController.text = selectedMission; // 제거

        // 미션 내용 자동 입력
        String missionContent = missionContents[selectedMission] ?? "해당 미션에 대한 내용이 없습니다.";
        contentController.text = "$selectedMission에 관련된 내용입니다. $missionContent";
      });

      print("선택된 미션: $selectedMission");
    }
  }

  // 게시글 작성 시 유효성 검사: 제목과 내용이 있어야 함
  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  // 작성 중인 내용이 있는지 확인
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

  /// 🔹 게시글 등록: Firebase에 게시글을 추가합니다.
  Future<void> submitPost() async {
    if (!isContentValid()) return;

    final communityService = CommunityService();
    try {
      // category는 "미션"으로 고정하거나 필요한 값을 넣으세요.
      final postId = await communityService.createPost(
        title: titleController.text,
        content: contentController.text,
        category: "미션",
        tags: tags,
      );
      print("게시글이 성공적으로 등록되었습니다. ID: $postId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게시글이 등록되었습니다.")),
      );
      // 등록 후 필요한 동작(페이지 이동 등)을 추가할 수 있습니다.
    } catch (error) {
      print("게시글 등록 중 오류 발생: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게시글 등록에 실패했습니다.")),
      );
    }
  }

  // 저장 안 함 선택 시 모든 입력 필드 초기화
  void discardDraft() {
    setState(() {
      titleController.clear();
      contentController.clear();
      tagController.clear();
      tags.clear();
    });
  }

  // close 아이콘 눌렀을 때 처리: 임시저장 여부 확인 후 페이지 종료
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

  @override
  void dispose() {
    _debounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  // 시스템 back 버튼 처리
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
          title: "미션 글 업로드",
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
              // WritingFormComponent 사용 (selectedMission은 selectedKeyword로만 전달)
              WritingFormComponent(
                titleController: titleController,
                contentController: contentController,
                titleFocusNode: titleFocusNode,
                contentFocusNode: contentFocusNode,
                customColors: customColors,
                selectedKeyword: selectedMission,
              ),
              const SizedBox(height: 34),
              // TagInputComponent 사용
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
