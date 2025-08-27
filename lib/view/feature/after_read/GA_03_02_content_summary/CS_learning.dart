// lib/view/feature/after_read/GA_03_02_content_summary/CS_learning.dart

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:readventure/view/components/my_divider.dart';
import '../../../../model/stage_data.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/user_service.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ LocalizedText/LocalizedList → String/List<String> 변환 헬퍼
import 'package:readventure/util/locale_text.dart';

class CSLearning extends ConsumerStatefulWidget {
  const CSLearning({Key? key}) : super(key: key);

  @override
  ConsumerState<CSLearning> createState() => _CSLearningState();
}

class _CSLearningState extends ConsumerState<CSLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  List<String> _keywords = [];

  // CustomAppBar 타이머 접근용
  final GlobalKey<CustomAppBar_2depth_8State> _appBarKey = GlobalKey<CustomAppBar_2depth_8State>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const ContentSummaryMain(),
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

  void _showAlertDialog(String answerText, String readingText, String activityType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          answerText: answerText,
          readingText: readingText,
          activityType: activityType,
        );
      },
    );
  }

  void _updateTextField(String newWord) {
    setState(() {
      final currentText = _controller.text;
      _controller.text = currentText.isEmpty ? newWord : '$currentText $newWord';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _updateKeywords(List<String> keywords) {
    setState(() {
      _keywords = keywords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final currentStage = ref.watch(currentStageProvider);

    if (currentStage == null) {
      return Scaffold(
        appBar: CustomAppBar_2depth_8(title: 'summary_game_title'.tr(), key: _appBarKey),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ 읽기 본문: LocalizedList → List<String> → join
    final List<String> segs = (currentStage.readingData == null)
        ? const <String>[]
        : llx(context, currentStage.readingData!.textSegments);
    final String readingText = segs.isNotEmpty ? segs.join(' ') : 'no_text_data'.tr();

    // ✅ 키워드: LocalizedList → List<String>
    final List<String> stageKeywords = (currentStage.brData == null)
        ? const <String>[]
        : llx(context, currentStage.brData!.keywords);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: 'summary_game_title'.tr(), key: _appBarKey),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () => _showHintDialog(stageKeywords, readingText),
          backgroundColor: customColors.secondary,
          shape: const CircleBorder(),
          child: Icon(Icons.emoji_objects_outlined, color: customColors.neutral100, size: 28),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀/부제 (부제는 LocalizedText → String)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TitleSection_withoutIcon(
                        customColors: customColors,
                        title: 'summary_instruction_three_sentences'.tr(),
                        subtitle: lx(context, currentStage.subdetailTitle), // ✅ 변경
                        author: "AI",
                      ),
                    ),
                    // 본문 텍스트
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Text_Section(text: readingText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BigDivider(),
                    BigDivider(),
                    const SizedBox(height: 8),
                    // 답안 입력
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Answer_Section(
                        controller: _controller,
                        customColors: customColors,
                      ),
                    ),
                    // 선택된 키워드 Chips
                    if (_keywords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _keywords
                              .map((k) => CustomChip(
                            label: k,
                            customColors: customColors,
                            borderRadius: 14.0,
                          ))
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
                    final elapsedSeconds = _appBarKey.currentState?.elapsedSeconds ?? 0;

                    final userId = ref.watch(userIdProvider);
                    if (userId != null) {
                      await ref.read(userServiceProvider).updateLearningTime(elapsedSeconds);
                      // ✔️ 요약은 feature #2
                      await updateFeatureCompletion(
                        stageId: currentStage.stageId,
                        featureNumber: 2,
                        isCompleted: true,);
                    }

                    _showAlertDialog(_controller.text, readingText, 'activity_summary'.tr());
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    disabledBackgroundColor: customColors.primary20,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: Text('submit'.tr(), style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 힌트: 1) 키워드, 2) 본문 자동 추가
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목/닫기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('hint_select_prompt'.tr(),
                            style: body_large_semi(context).copyWith(color: customColors.neutral30)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        // 옵션1: 키워드
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () => setState(() => selectedOption = 1),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 1 ? customColors.primary10 : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 1 ? Border.all(color: customColors.primary!) : null,
                              ),
                              child: Center(
                                child: Text(
                                  'keyword_count'.tr(args: [stageKeywords.length.toString()]),
                                  style: body_small_semi(context).copyWith(color: customColors.neutral30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // 옵션2: 본문 자동 추가
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () => setState(() => selectedOption = 2),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: selectedOption == 2 ? customColors.primary10 : customColors.neutral90,
                                borderRadius: BorderRadius.circular(16.0),
                                border: selectedOption == 2 ? Border.all(color: customColors.primary!) : null,
                              ),
                              child: Center(
                                child: Text(
                                  'auto_add_body'.tr(),
                                  style: body_small_semi(context).copyWith(color: customColors.neutral30),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // 완료 버튼
                    selectedOption == null
                        ? ButtonPrimary20_noPadding(
                      function: () {},
                      title: 'select_done'.tr(),
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
                      title: 'select_done'.tr(),
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
