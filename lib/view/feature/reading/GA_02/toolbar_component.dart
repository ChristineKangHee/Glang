/// File: toolbar_component.dart
/// Purpose: 읽기 화면에서 텍스트를 선택할 때 나타나는 툴바 위젯
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2025-02-07 by 강희
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
import 'notedialog.dart';
import 'reading_chatbot.dart';
import 'package:easy_localization/easy_localization.dart'; // 추가

/// 읽기 화면에서 텍스트를 선택할 때 나타나는 툴바 위젯
class Toolbar extends StatefulWidget {
  final double toolbarWidth; // 툴바의 너비
  final double toolbarHeight; // 툴바의 높이
  final BuildContext context;
  final TextSelectionDelegate delegate;
  final dynamic customColors;
  final String stageId; // 현재 스테이지 ID
  final String subdetailTitle; // 메모 목록에 표시될 제목
  final ReadingData readingData; // 읽기 관련 데이터

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
    return IntrinsicWidth(
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton('toolbar_note', () => _showNoteDialog(context, widget.delegate), false),
            _buildToolbarButton('toolbar_interpret', () => _showWordOrSentencePopup(context, widget.delegate), false),
            _buildToolbarButton('toolbar_chatbot', () => _navigateToChatbot(context, widget.delegate), true),
          ],
        ),
      ),
    );
  }


  /// 툴바 버튼을 생성하는 메서드
  Widget _buildToolbarButton(String label, VoidCallback onPressed, bool isLast) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.tr(),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
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

  /// 메모 다이얼로그 표시 메서드
  void _showNoteDialog(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NoteDialog(
          selectedText: selectedText,
          noteController: _noteController,
          customColors: widget.customColors,
          stageId: widget.stageId,
          subdetailTitle: widget.subdetailTitle,
        );
      },
    );
  }

  /// 단어 또는 문장 해석 팝업 표시 메서드
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

  /// 선택된 텍스트가 단어인지 확인하는 메서드
  bool _isWordSelected(String selectedText) {
    return selectedText.split(' ').length == 1;
  }

  /// 챗봇 화면으로 이동하는 메서드
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

///
/// Read_Toolbar: 텍스트 선택 시 나타나는 툴바를 커스터마이징하는 클래스
/// stageId와 subdetailTitle을 추가로 받아 Toolbar에 전달합니다.
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
