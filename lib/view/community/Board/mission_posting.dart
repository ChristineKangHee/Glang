import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class MissionPostPage extends ConsumerStatefulWidget {
  @override
  _MissionPostPageState createState() => _MissionPostPageState();
}

class _MissionPostPageState extends ConsumerState<MissionPostPage> {
  final List<String> keywordList = [
    '자기 개발', '창의성', '성장', '행복', '도전', '미래', '인간 관계', '건강',
    '목표 설정', '열정', '긍정적 사고', '자아 실현', '자기 관리'
  ];

  String selectedKeyword = ''; // 에세이 전용 키워드
  bool isSpinning = false;
  late Timer _timer;
  String selectedCategory = ''; // 코스, 인사이트, 에세이 등 선택
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

    void onTextChanged() {
      setState(() {});

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(seconds: 2), () {
        if (isContentValid()) {
          saveDraft();
        }
      });
    }

    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
    tagController.addListener(() => setState(() {}));
    titleFocusNode.addListener(() => setState(() {}));
    contentFocusNode.addListener(() => setState(() {}));
  }

  // essay 작성 시 유효성 검사: 키워드 또는 제목이 있고, 내용이 있어야 함
  bool isContentValid() {
    return (((selectedKeyword.isNotEmpty) || titleController.text.isNotEmpty) &&
        contentController.text.isNotEmpty);
  }

  // 작성 중인 내용이 있는지 확인 (essay 전용 키워드, 제목, 내용)
  bool hasUnsavedChanges() {
    return selectedKeyword.isNotEmpty ||
        titleController.text.isNotEmpty ||
        contentController.text.isNotEmpty;
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

  // 임시저장 (essay일 경우 [키워드] + 제목 결합)
  void saveDraft() {
    if (!isContentValid()) return;
    final fullTitle = selectedKeyword.isNotEmpty
        ? "[$selectedKeyword] ${titleController.text}"
        : titleController.text;
    print("Draft saved: title=$fullTitle, content=${contentController.text}");
  }

  void submitPost() {
    if (!isContentValid()) return;
    final fullTitle = selectedKeyword.isNotEmpty
        ? "[$selectedKeyword] ${titleController.text}"
        : titleController.text;
    print("Post submitted: title=$fullTitle, content=${contentController.text}, tags=$tags");
  }

  // 임시저장 여부를 묻는 팝업
  Future<bool?> _confirmDraftSave() async {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("임시저장"),
          content: Text("작성중인 글이 있습니다. 임시저장하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("취소"),
            ),
            TextButton(onPressed: () {
              discardDraft();
              Navigator.of(context).pop(false);
            }, child: Text("저장 안 함")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("임시저장"),
            ),
          ],
        );
      },
    );
  }
// 저장 안 함 선택 시 모든 입력 필드 초기화
  void discardDraft() {
    setState(() {
      titleController.clear();
      contentController.clear();
      tagController.clear();
      tags.clear();
      selectedKeyword = '';
    });
  }
  // close 아이콘 눌렀을 때 처리: 임시저장 여부 확인 후 페이지 종료
  void _handleClose() async {
    if (hasUnsavedChanges()) {
      final result = await _confirmDraftSave();
      if (result == null) return; // 취소 시 아무 작업 안 함
      if (!result) {
        discardDraft();
      } else {
        saveDraft();
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (isSpinning) _timer.cancel();
    _debounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  // 돌리기 버튼 클릭 시 애니메이션 시작 (랜덤 키워드 선택)
  void startSpinning() {
    setState(() {
      isSpinning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % keywordList.length;
      });
    });

    Future.delayed(Duration(seconds: 3), () {
      _timer.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = keywordList[currentIndex];
      });
    });
  }
// 에세이 선택 시 키워드만 있고, 다른 입력이 없을 때 키워드 삭제
  void handleCategorySelection(String category) async {
    if (category == '코스' || category == '인사이트') {
      if (hasUnsavedChanges()) {
        final result = await _confirmDraftSave();
        if (result == null) return;
        if (!result) {
          discardDraft();
        } else {
          saveDraft();
        }
      }
      setState(() {
        selectedCategory = category;
        selectedKeyword = ''; // 에세이 키워드 삭제
      });
    } else if (category == '에세이') {
      setState(() {
        selectedCategory = category;
      });
      showKeywordSelectionDialog(context);
    }
  }
  // 에세이 선택 시 키워드 다이얼로그 호출
  void showKeywordSelectionDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _KeywordSelectionDialog(keywordList);
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedKeyword = result;
      });
    }
  }

  // 시스템 back 버튼 처리
  Future<bool> _onWillPop() async {
    if (hasUnsavedChanges()) {
      final result = await _confirmDraftSave();
      if (result == null) return false;
      if (result) saveDraft();
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
          title: "글쓰기",
          onIconPressed: _handleClose, // close 아이콘 눌렀을 때 unsaved 체크
          actions: [
            TextButton(
              onPressed: isContentValid() ? saveDraft : null,
              child: Text(
                "임시저장",
                style: body_xsmall_semi(context).copyWith(
                  color: isContentValid() ? customColors.primary : customColors.neutral80,
                ),
              ),
            ),
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
              // 게시판 선택: 코스, 인사이트, 에세이
              ChooseCategory(context, customColors),
              SizedBox(height: 34),
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
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: titleFocusNode.hasFocus ? customColors.primary! : customColors.neutral80!,
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

  Widget ChooseCategory(BuildContext context, CustomColors customColors) {
    return Column(
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
      ],
    );
  }

  // 게시판 버튼: 코스, 인사이트 클릭 시 unsaved 체크 후 essay 전용 키워드 삭제
  Widget buildCategoryButton(String category, CustomColors customColors) {
    return GestureDetector(
      onTap: () async {
        // 코스, 인사이트 선택 시 unsaved 체크 후 essay 키워드 삭제
        if (category == '코스' || category == '인사이트') {
          if (hasUnsavedChanges()) {
            final result = await _confirmDraftSave();
            if (result == null) return; // 취소 시 동작 중단
            if (result) saveDraft();
          }
          setState(() {
            selectedCategory = category;
            selectedKeyword = ''; // essay 전용 키워드 삭제
          });
        } else if (category == '에세이') {
          setState(() {
            selectedCategory = category;
          });
          showKeywordSelectionDialog(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: selectedCategory == category ? customColors.primary : customColors.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: selectedCategory == category ? Colors.transparent : customColors.neutral80!),
          ),
        ),
        child: Text(
          category,
          style: body_xsmall_semi(context).copyWith(
            color: selectedCategory == category ? customColors.white : customColors.neutral80,
          ),
        ),
      ),
    );
  }

  // 글 작성 폼: 에세이일 경우 selectedKeyword가 있으면 [키워드]와 제목 입력 필드 함께 표시
  Widget WritingForm(BuildContext context, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectedKeyword.isNotEmpty
                  ? Row(
                children: [
                  Text(
                    "[$selectedKeyword]",
                    style: body_medium_semi(context).copyWith(color: customColors.primary),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
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
                        hintStyle: body_medium_semi(context)
                            .copyWith(color: customColors.neutral60),
                      ),
                      style: body_medium_semi(context),
                    ),
                  ),
                ],
              )
                  : TextField(
                controller: titleController,
                focusNode: titleFocusNode,
                decoration: InputDecoration(
                  hintText: "제목을 입력하세요",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: titleFocusNode.hasFocus ? customColors.primary! : customColors.neutral80!,
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
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText:
                  "내용을 입력해주세요.\n1. 타인에게 불쾌감을 주지 않는 내용\n2. 개인정보 보호 규정 준수\n3. 욕설 및 비하 발언 금지",
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
      ],
    );
  }
}

// 에세이 전용 키워드 선택 다이얼로그
class _KeywordSelectionDialog extends ConsumerStatefulWidget {
  final List<String> keywordList;
  _KeywordSelectionDialog(this.keywordList);

  @override
  _KeywordSelectionDialogState createState() => _KeywordSelectionDialogState();
}

class _KeywordSelectionDialogState extends ConsumerState<_KeywordSelectionDialog> {
  bool isSpinning = false;
  int currentIndex = 0;
  String selectedKeyword = '';
  late Timer _timer;

  void startSpinning() {
    setState(() {
      isSpinning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.keywordList.length;
      });
    });

    Future.delayed(Duration(seconds: 3), () {
      _timer.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = widget.keywordList[currentIndex];
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return AlertDialog(
      title: Text(
        "랜덤 키워드 뽑기",
        style: body_medium_semi(context),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.keywordList[currentIndex],
                style: body_large_semi(context).copyWith(color: customColors.primary),
                key: ValueKey<int>(currentIndex),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: isSpinning ? null : startSpinning,
                child: Text(isSpinning ? "로딩 중..." : "돌리기"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: selectedKeyword.isEmpty
                    ? null
                    : () {
                  Navigator.of(context).pop(selectedKeyword);
                  print("선택된 키워드: $selectedKeyword");
                },
                child: Text("작성하기"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
