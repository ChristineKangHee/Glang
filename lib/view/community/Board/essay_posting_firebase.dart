// 필요한 패키지들 임포트
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'Component/keyword_selection.dart';
import 'Component/taginput_component.dart';
import 'Component/writingform_component.dart';
import 'community_service.dart';

// 에세이 게시 페이지 클래스
class EssayPostPage extends ConsumerStatefulWidget {
  @override
  _EssayPostPageState createState() => _EssayPostPageState();
}

class _EssayPostPageState extends ConsumerState<EssayPostPage> {
  final CommunityService _communityService = CommunityService(); // 커뮤니티 서비스 인스턴스
  final List<String> keywordList = [ // 키워드 목록
    '자기 개발', '창의성', '성장', '행복', '도전', '미래', '인간 관계', '건강',
    '목표 설정', '열정', '긍정적 사고', '자아 실현', '자기 관리'
  ];

  String selectedKeyword = ''; // 선택된 키워드
  bool isSpinning = false; // 회전 애니메이션 여부
  late Timer _timer; // 타이머
  TextEditingController titleController = TextEditingController(); // 제목 입력 컨트롤러
  TextEditingController contentController = TextEditingController(); // 내용 입력 컨트롤러
  TextEditingController tagController = TextEditingController(); // 태그 입력 컨트롤러
  List<String> tags = []; // 태그 목록
  Timer? _debounce; // 디바운스 타이머
  int currentIndex = 0; // 현재 인덱스

  // FocusNode 선언 (제목, 내용 입력 필드에서의 포커스 관리)
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 랜덤 키워드 선택
    final random = Random();
    selectedKeyword = keywordList[random.nextInt(keywordList.length)];

    // 프레임 이후에 키워드 선택 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showKeywordSelectionDialog(context);
    });

    // 입력 필드의 텍스트가 변경될 때마다 화면 갱신
    void onTextChanged() {
      setState(() {});
    }

    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
    tagController.addListener(() => setState(() {}));
  }

  // 에세이 작성 시 유효성 검사: 키워드 또는 제목이 있고, 내용이 있어야 함
  bool isContentValid() {
    return (((selectedKeyword.isNotEmpty) || titleController.text.isNotEmpty) &&
        contentController.text.isNotEmpty);
  }

  // 작성 중인 내용이 있는지 확인 (에세이 전용 키워드, 제목, 내용)
  bool hasUnsavedChanges() {
    return selectedKeyword.isNotEmpty ||
        titleController.text.isNotEmpty ||
        contentController.text.isNotEmpty;
  }

  // 태그 추가 함수
  void addTag() {
    if (tagController.text.isNotEmpty && tags.length < 3) {
      setState(() {
        tags.add(tagController.text);
        tagController.clear();
      });
    }
  }

  // 태그 삭제 함수
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
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

  // 등록 버튼 클릭 시 호출되는 함수
  Future<void> submitPost() async {
    if (!isContentValid()) return;
    final fullTitle = selectedKeyword.isNotEmpty
        ? "[$selectedKeyword] ${titleController.text}"
        : titleController.text;
    try {
      // 커뮤니티 서비스에 게시글 작성 요청
      await _communityService.createPost(
        title: fullTitle,
        content: contentController.text,
        category: "에세이", // 에세이로 고정
        tags: tags,
      );
      discardDraft();
      // 게시글 작성 후 페이지 종료
      Navigator.of(context).pop();
    } catch (e) {
      // 게시글 작성 실패 시 알림 다이얼로그 표시
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

  // close 아이콘 눌렀을 때 처리: 임시저장 여부 확인 후 페이지 종료
  void _handleClose() async {
    if (hasUnsavedChanges()) {
      if (selectedKeyword.isNotEmpty && titleController.text.isEmpty && contentController.text.isEmpty) {
        Navigator.of(context).pop();
      } else {
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
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    if (isSpinning) _timer.cancel(); // 타이머 취소
    _debounce?.cancel(); // 디바운스 타이머 취소
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

    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % keywordList.length;
      });
    });

    Future.delayed(Duration(seconds: 1), () {
      _timer.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = keywordList[currentIndex];
      });
    });
  }

  // 에세이 선택 시 키워드 다이얼로그 호출
  void showKeywordSelectionDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return KeywordSelectionDialog(keywordList);
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
      if (selectedKeyword.isNotEmpty && titleController.text.isEmpty && contentController.text.isEmpty) {
        Navigator.of(context).pop();
      } else {
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
          title: "에세이",
          onIconPressed: _handleClose,
          actions: [
            // 등록 버튼
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
                selectedKeyword: selectedKeyword, // 에세이 전용 키워드 전달
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
