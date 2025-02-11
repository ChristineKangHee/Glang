import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../model/stage_data.dart';
import '../../../../theme/theme.dart';
import '../../../home/stage_provider.dart';
import '../widget/answer_section.dart';
import '../widget/CustomAlertDialog.dart';
import '../widget/custom_chip.dart';
import '../widget/text_section.dart';
import '../widget/title_section_learning.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CS_main.dart';
import '../choose_activities.dart';

/// ConsumerStatefulWidget으로 변경하여 Riverpod의 ref 사용
class CSLearning extends ConsumerStatefulWidget {
  const CSLearning({Key? key}) : super(key: key);

  @override
  ConsumerState<CSLearning> createState() => _CSLearningState();
}

class _CSLearningState extends ConsumerState<CSLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  List<String> _keywords = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);

    // 예시: 화면이 뜨자마자 ContentSummaryMain 다이얼로그 띄우기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ContentSummaryMain();
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog();
      },
    );
  }

  // 텍스트 필드에 단어 추가
  void _updateTextField(String newWord) {
    setState(() {
      final currentText = _controller.text;
      _controller.text = currentText.isEmpty ? newWord : '$currentText $newWord';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  // 키워드 업데이트 함수
  void _updateKeywords(List<String> keywords) {
    setState(() {
      _keywords = keywords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    // currentStageProvider를 구독하여 현재 선택된 스테이지 데이터 가져오기
    final currentStage = ref.watch(currentStageProvider);

    // 아직 데이터가 없으면 로딩 인디케이터 표시
    if (currentStage == null) {
      return Scaffold(
        appBar: CustomAppBar_2depth_8(title: "내용 요약 게임"),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 읽기 중(READING) 데이터의 textSegments를 이어붙여 본문 텍스트 구성
    final readingText = currentStage.readingData?.textSegments.join(" ")
        ?? "텍스트 데이터가 없습니다.";
    // 읽기 전(BR) 데이터의 키워드 배열 가져오기
    final stageKeywords = currentStage.brData?.keywords ?? [];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "내용 요약 게임"),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () {
            _showHintDialog(stageKeywords, readingText);
          },
          backgroundColor: customColors.secondary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.emoji_objects_outlined,
            color: customColors.neutral100,
            size: 28,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀 영역 (스테이지 제목 활용)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TitleSection_withoutIcon(
                        customColors: customColors,
                        title: "글을 3문장으로 요약해주세요!",
                        subtitle: currentStage.subdetailTitle,
                        author: "AI",
                      ),
                    ),
                    // 본문 텍스트 영역 → 읽기 중 데이터 이용
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Text_Section(
                            text: readingText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BigDivider(),
                    BigDivider(),
                    const SizedBox(height: 8),
                    // 사용자 입력 영역
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Answer_Section(
                        controller: _controller,
                        customColors: customColors,
                      ),
                    ),
                    // 선택된 키워드 Chip들 표시
                    if (_keywords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _keywords
                              .map(
                                (keyword) => CustomChip(
                              label: keyword,
                              customColors: customColors,
                              borderRadius: 14.0,
                            ),
                          )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 제출 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      // Feature2(내용 요약 게임)는 feature 번호 2에 해당하므로,
                      // _updateFeatureCompletion 함수를 호출하여 Firestore에 업데이트합니다.
                      await updateFeatureCompletion(currentStage, 2, true);
                    }
                    _showAlertDialog();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    disabledBackgroundColor: customColors.primary20,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: const Text("제출하기", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 힌트 다이얼로그: 옵션 1은 키워드, 옵션 2는 본문 자동 추가 처리
  void _showHintDialog(List<String> stageKeywords, String readingText) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    int? selectedOption;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목 및 닫기 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "힌트 2가지 중 하나를 선택해주세요",
                          style: body_large_semi(context)
                              .copyWith(color: customColors.neutral30),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        // 옵션 1: brData의 키워드를 사용
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () {
                              setState(() {
                                selectedOption = 1;
                              });
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 1
                                    ? customColors.primary10
                                    : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 1
                                    ? Border.all(
                                    color: customColors.primary ?? Colors.blue)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "키워드 ${stageKeywords.length}개",
                                  style: body_small_semi(context)
                                      .copyWith(color: customColors.neutral30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // 옵션 2: 읽기 중 본문 자동 추가
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () {
                              setState(() {
                                selectedOption = 2;
                              });
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 2
                                    ? customColors.primary10
                                    : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 2
                                    ? Border.all(
                                    color: customColors.primary ?? Colors.blue)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "본문 자동 추가",
                                  style: body_small_semi(context)
                                      .copyWith(color: customColors.neutral30),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // 선택 완료 버튼: 선택에 따라 동작 분기
                    selectedOption == null
                        ? ButtonPrimary20_noPadding(
                      function: () {},
                      title: '선택 완료',
                      condition: "null",
                    )
                        : ButtonPrimary_noPadding(
                      function: () {
                        Navigator.of(context).pop();
                        if (selectedOption == 1) {
                          _updateKeywords(stageKeywords);
                        } else if (selectedOption == 2) {
                          _updateTextField(readingText);
                        }
                      },
                      title: '선택 완료',
                      condition: "not null",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
