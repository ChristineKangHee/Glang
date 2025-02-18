import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:readventure/model/reading_data.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/feature/reading/GA_02/sentence_interpretation.dart';
import 'package:readventure/view/feature/reading/GA_02/word_interpretation.dart';
import '../../../../viewmodel/memo_notifier.dart';
import '../../after_read/widget/answer_section.dart';
import 'reading_chatbot.dart';

class Toolbar extends StatefulWidget {
  final double toolbarWidth;
  final double toolbarHeight;
  final BuildContext context;
  final TextSelectionDelegate delegate;
  final dynamic customColors;
  final String stageId;           // 현재 스테이지의 ID
  final String subdetailTitle;    // StageData의 subdetailTitle (메모 목록에 보여질 제목)
  final ReadingData readingData;  // 읽기 화면 관련 데이터 (예: textSegments 등)

  const Toolbar({
    Key? key,
    required this.toolbarWidth,
    required this.toolbarHeight,
    required this.context,
    required this.delegate,
    required this.customColors,
    required this.stageId,
    required this.subdetailTitle,
    required this.readingData,
  }) : super(key: key);

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.toolbarWidth,
      height: widget.toolbarHeight,
      decoration: BoxDecoration(
        color: widget.customColors.neutral90,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 30,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton('메모', () => _showNoteDialog(context, widget.delegate), false),
          _buildToolbarButton('해석', () => _showWordOrSentencePopup(context, widget.delegate), false),
          _buildToolbarButton('챗봇', () => _navigateToChatbot(context, widget.delegate), true),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed, bool isLast) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: body_small_semi(context).copyWith(
              color: widget.customColors.neutral0,
              decoration: TextDecoration.none,
            ),
          ),
          if (!isLast)
            VerticalDivider(
              color: widget.customColors.neutral60,
            ),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _NoteDialog(
          selectedText: selectedText,
          noteController: _noteController,
          customColors: widget.customColors,
          stageId: widget.stageId,
          subdetailTitle: widget.subdetailTitle,
        );
      },
    );
  }

  void _showWordOrSentencePopup(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (_isWordSelected(selectedText)) {
      showWordPopup(
        context: context,
        selectedText: selectedText,
        textSegments: widget.readingData.textSegments,
        customColors: widget.customColors,
        stageId: widget.stageId,
        subdetailTitle: widget.subdetailTitle,
      );
    } else {
      showSentencePopup(
        context: context,
        selectedText: selectedText,
        textSegments: widget.readingData.textSegments,
        customColors: widget.customColors,
        stageId: widget.stageId,
        subdetailTitle: widget.subdetailTitle,
      );
    }
  }

  bool _isWordSelected(String selectedText) {
    return selectedText.split(' ').length == 1;
  }

  void _navigateToChatbot(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (selectedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBot(
            selectedText: selectedText,
            readingData: widget.readingData,
          ),
        ),
      );
    }
  }
}

class _NoteDialog extends StatefulWidget {
  final String selectedText;
  final TextEditingController noteController;
  final dynamic customColors;
  final String stageId;
  final String subdetailTitle;

  const _NoteDialog({
    Key? key,
    required this.selectedText,
    required this.noteController,
    required this.customColors,
    required this.stageId,
    required this.subdetailTitle,
  }) : super(key: key);

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late Color saveButtonColor;
  bool isQuestionIncluded = false;

  @override
  void initState() {
    super.initState();
    saveButtonColor = widget.customColors.primary20;
    widget.noteController.addListener(() {
      setState(() {
        saveButtonColor = widget.noteController.text.isNotEmpty
            ? widget.customColors.primary
            : widget.customColors.primary20;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: widget.customColors.neutral100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '메모',
                textAlign: TextAlign.center,
                style: body_small_semi(context).copyWith(
                  color: widget.customColors.neutral30,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '선택된 문장',
                  style: body_xsmall_semi(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: widget.customColors.neutral90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectedText,
                    style: body_xsmall(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // 메모 입력 영역 (프로젝트에 맞게 커스텀 위젯 적용)
              Answer_Section_No_Title(
                controller: widget.noteController,
                customColors: widget.customColors,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: widget.customColors.neutral90,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: saveButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: saveButtonColor == widget.customColors.primary20
                            ? null
                            : () async {
                          final note = widget.noteController.text.trim();
                          if (note.isNotEmpty) {
                            // memoProvider를 통해 Firestore의 subcollection에 메모 저장
                            await ProviderScope.containerOf(context)
                                .read(memoProvider.notifier)
                                .addMemo(
                              stageId: widget.stageId,
                              subdetailTitle: widget.subdetailTitle,
                              selectedText: widget.selectedText,
                              note: note,
                            );
                            debugPrint('메모 저장: $note');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.all(16),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: widget.customColors.neutral60.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '메모가 저장되었어요.',
                                      style: body_small_semi(context)
                                          .copyWith(color: widget.customColors.neutral100),
                                    ),
                                  ],
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          '저장',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// Read_Toolbar: MaterialTextSelectionControls를 상속하여 텍스트 선택 시 나타나는 툴바를 커스터마이징
/// stageId와 subdetailTitle을 추가 매개변수로 받아 Toolbar에 전달합니다.
///
class Read_Toolbar extends MaterialTextSelectionControls {
  final dynamic customColors;
  final ReadingData readingData;
  final String stageId;
  final String subdetailTitle;

  Read_Toolbar({
    required this.customColors,
    required this.readingData,
    required this.stageId,
    required this.subdetailTitle,
  });

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset position,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition,
      ) {
    const double toolbarHeight = 50;
    const double toolbarWidth = 135;

    final screenSize = MediaQuery.of(context).size;
    double leftPosition =
        (endpoints.first.point.dx + endpoints.last.point.dx) / 2 - toolbarWidth / 2 + 16;
    double topPosition =
        endpoints.first.point.dy + globalEditableRegion.top - toolbarHeight - 32.0;

    leftPosition = leftPosition.clamp(0.0, screenSize.width - toolbarWidth);
    topPosition = topPosition.clamp(0.0, screenSize.height - toolbarHeight);

    return Stack(
      children: [
        Positioned(
          left: leftPosition,
          top: topPosition,
          child: Toolbar(
            toolbarWidth: toolbarWidth,
            toolbarHeight: toolbarHeight,
            context: context,
            delegate: delegate,
            customColors: customColors,
            readingData: readingData,
            stageId: stageId,
            subdetailTitle: subdetailTitle,
          ),
        ),
      ],
    );
  }
}
