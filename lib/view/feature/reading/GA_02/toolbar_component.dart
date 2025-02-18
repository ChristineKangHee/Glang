/// File: toolbar_component.dart
/// Purpose: 읽기 중 드래그 후 나타나는 툴바 및 단어/문장 해석 팝업 처리
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 (수정: ChatGPT API 연동 및 DebateGPTService 참고)
/// 수정: API 응답 파싱 실패나 호출 실패 시 예외 대신 기본값("정보 없음")을 반환하도록 변경

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readventure/view/feature/reading/GA_02/sentence_interpretation.dart';
import 'package:readventure/view/feature/reading/GA_02/word_interpretation.dart';

import '../../../../theme/theme.dart';
import 'reading_chatbot.dart';
import '../../../../theme/font.dart';
import '../../after_read/widget/answer_section.dart';
// ReadingData의 경로에 맞게 import 수정
import 'package:readventure/model/reading_data.dart';

class Toolbar extends StatefulWidget {
  final double toolbarWidth;
  final double toolbarHeight;
  final BuildContext context;
  final TextSelectionDelegate delegate;
  final customColors;
  final ReadingData readingData; // 추가: 현재 읽기 데이터를 전달

  const Toolbar({
    Key? key,
    required this.toolbarWidth,
    required this.toolbarHeight,
    required this.context,
    required this.delegate,
    required this.customColors,
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

  // void _highlightText(BuildContext context, TextSelectionDelegate delegate) {
  //   final String selectedText =
  //   delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
  //   if (selectedText.isNotEmpty) {
  //     final TextStyle highlightedStyle = TextStyle(
  //       color: Colors.yellow,
  //       backgroundColor: Colors.yellow.withOpacity(0.3),
  //       decoration: TextDecoration.underline,
  //     );
  //     // 하이라이트 적용 로직 추가 가능
  //   }
  // }

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
        );
      },
    );
  }

  void _showWordOrSentencePopup(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (_isWordSelected(selectedText)) {
      // 읽기 데이터의 textSegments와 customColors를 전달합니다.
      showWordPopup(
        context: context,
        selectedText: selectedText,
        textSegments: widget.readingData.textSegments,
        customColors: widget.customColors,
      );
    } else {
      showSentencePopup(
        context: context,
        selectedText: selectedText,
        textSegments: widget.readingData.textSegments,
        customColors: widget.customColors,
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
          builder: (context) => ChatBot(selectedText: selectedText, readingData: widget.readingData,),
        ),
      );
    }
  }
}

class _NoteDialog extends StatefulWidget {
  final String selectedText;
  final TextEditingController noteController;
  final customColors;

  const _NoteDialog({
    Key? key,
    required this.selectedText,
    required this.noteController,
    required this.customColors,
  }) : super(key: key);

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late Color saveButtonColor;
  bool isQuestionIncluded = false; // 질문 포함 여부 상태

  @override
  void initState() {
    super.initState();
    saveButtonColor = widget.customColors.primary20;

    // TextField 변경에 따라 버튼 색상 업데이트
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
                            : () {
                          final note = widget.noteController.text.trim();
                          if (note.isNotEmpty) {
                            debugPrint('메모 저장: $note');
                            debugPrint('질문 포함 상태: $isQuestionIncluded');
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
                              onVisible: () {
                                Future.delayed(const Duration(seconds: 1), () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                });
                              },
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
