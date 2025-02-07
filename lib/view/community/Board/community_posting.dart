import 'dart:async';
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
  final List<String> keywordList = [
    '자기 개발', '창의성', '성장', '행복', '도전', '미래', '인간 관계', '건강',
    '목표 설정', '열정', '긍정적 사고', '자아 실현', '자기 관리'
  ]; // 키워드 목록
  String selectedKeyword = ''; // 선택된 키워드
  bool isSpinning = false; // 회전 중인지 여부
  late Timer _timer; // 타이머 (회전 시간 제어)
  String selectedCategory = ''; // No default selection
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List<String> tags = [];
  Timer? _debounce; // Debounce timer

  // 애니메이션을 위한 Wheel Picker 애니메이션
  int currentIndex = 0;

  // Define FocusNode
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    void onTextChanged() {
      // Update UI instantly
      setState(() {});

      // Apply debounce (execute after 2 seconds)
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(seconds: 2), () {
        if (isContentValid()) {
          saveDraft();
        }
      });
    }

    // Add listeners
    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
    tagController.addListener(() => setState(() {}));
    titleFocusNode.addListener(() => setState(() {}));
    contentFocusNode.addListener(() => setState(() {}));
  }

  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
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

  void saveDraft() {
    if (!isContentValid()) return;
    print("Draft saved: title=${titleController.text}, content=${contentController.text}");
  }

  void submitPost() {
    if (!isContentValid()) return;
    print("Post submitted: title=${titleController.text}, content=${contentController.text}, tags=$tags");
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 해제
    _debounce?.cancel(); // Clean up timer
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  // 돌리기 버튼 클릭 시 애니메이션 시작
  void startSpinning() {
    setState(() {
      isSpinning = true;
    });

    // 3초간 빠르게 회전
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % keywordList.length;
      });
    });

    // 3초 후 회전 종료
    Future.delayed(Duration(seconds: 3), () {
      _timer.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = keywordList[currentIndex]; // 최종 선택된 키워드
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_9(
        title: "글쓰기",
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
            // 카테고리 선택 (에세이, 코스 등)
            ChooseCategory(context, customColors),

            SizedBox(height: 34),

            // 글 작성
            WritingForm(context, customColors),


            SizedBox(height: 34),

            // 태그 입력
            TagInput(context, customColors),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget TagInput(BuildContext context, CustomColors customColors) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
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
                      enabled: tags.length < 3, // Disable the TextField when 3 tags are added
                    ),
                  ),
                  ElevatedButton(
                    onPressed: tagController.text.isNotEmpty && tags.length < 3
                        ? addTag
                        : null, // Disable button if 3 tags are added
                    child: Text(
                      "추가",
                      style: body_xsmall_semi(context).copyWith(
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

  // Add the below method to handle the pop-up for keyword selection
  // 수정된 다이얼로그 호출 함수
  void showKeywordSelectionDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return _KeywordSelectionDialog(keywordList);
      },
    );

    // 결과가 있으면 제목 입력란에 키워드를 넣고 편집중 상태로 포커스를 준다.
    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedKeyword = result;
        titleController.text = result;
      });
      titleFocusNode.requestFocus();
    }
  }

  Widget ChooseCategory(BuildContext context, CustomColors customColors) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
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

  Widget WritingForm(BuildContext context, CustomColors customColors) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
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
                  crossAxisAlignment: CrossAxisAlignment.start, // Align inner content to the left as well
                  children: [
                    TextField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      decoration: InputDecoration(
                        hintText: "제목을 입력하세요",
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: titleFocusNode.hasFocus ? customColors.primary! : customColors.neutral80!,
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
            ],
          );
  }

  Widget buildCategoryButton(String category, CustomColors customColors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
        // Check if '에세이' is selected to trigger the dialog
        if (category == '에세이') {
          showKeywordSelectionDialog(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: selectedCategory == category ? customColors.primary : customColors.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: selectedCategory == category ? Colors.transparent : customColors.neutral80!),
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
}
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
      title: Text("랜덤 키워드 뽑기", style: body_medium_semi(context), textAlign: TextAlign.center,),
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
                // 선택된 키워드가 없으면 비활성화, 있으면 선택 결과를 반환
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