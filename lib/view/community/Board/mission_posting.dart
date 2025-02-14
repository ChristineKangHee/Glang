import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
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

    // Automatically show the bottom sheet when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => showCourseSelectionSheet(context));

    void onTextChanged() {
      setState(() {});
    }

    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
    tagController.addListener(() => setState(() {}));
  }
  // 사용 예시: BottomSheet 띄우기
  void showCourseSelectionSheet(BuildContext context) async {
    final selectedMission = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,  // Allow custom height
      isDismissible: false,  // Prevent dismissing by tapping outside
      enableDrag: false,
      builder: (context) => CourseSelectionBottomSheet(),
    );

    if (selectedMission != null) {
      setState(() {
        this.selectedMission = selectedMission;
        titleController.text = selectedMission;

        // 미션 내용 자동 입력
        String missionContent = missionContents[selectedMission] ?? "해당 미션에 대한 내용이 없습니다.";
        contentController.text = "$selectedMission에 관련된 내용입니다. $missionContent"; // 미션 내용 자동 입력
      });

      print("선택된 미션: $selectedMission");
    }
  }

  // essay 작성 시 유효성 검사: 제목과 내용이 있어야 함
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

  void submitPost() {
    if (!isContentValid()) return;
    print("Post submitted: title=${titleController.text}, content=${contentController.text}, tags=$tags");
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
      Navigator.of(context).pop(); // No unsaved changes, just pop the page
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

  // 에세이 선택 시 키워드 다이얼로그 호출 (삭제됨)

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
      return false; // Prevent the default back action until the dialog is handled
    }
    return true; // No unsaved changes, allow normal back action
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar_2depth_9(
          title: "미션 글 업로드",
          onIconPressed: _handleClose, // close 아이콘 눌렀을 때 unsaved 체크
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
              // 글 작성 폼 (제목, 내용)
              WritingForm(context, customColors),
              SizedBox(height: 34),
              // 태그 입력 영역
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
