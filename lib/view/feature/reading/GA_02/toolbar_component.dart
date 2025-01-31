/// File: tpolbar_component.dart
/// Purpose: 읽기중 드래그 후 나타나는 툴바 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import 'reading_chatbot.dart';
import '../../../../theme/font.dart';
import '../../after_read/widget/answer_section.dart';

class Toolbar extends StatefulWidget {
  final double toolbarWidth;
  final double toolbarHeight;
  final BuildContext context;
  final TextSelectionDelegate delegate;
  final customColors;

  const Toolbar({
    Key? key,
    required this.toolbarWidth,
    required this.toolbarHeight,
    required this.context,
    required this.delegate,
    required this.customColors,
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
          if (!isLast) VerticalDivider(color: widget.customColors.neutral60,),
        ],
      ),
    );
  }

  void _highlightText(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (selectedText.isNotEmpty) {
      final TextStyle highlightedStyle = TextStyle(
        color: Colors.yellow,
        backgroundColor: Colors.yellow.withOpacity(0.3),
        decoration: TextDecoration.underline,
      );
      // Apply your highlight logic here
    }
  }

  void _showNoteDialog(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    final TextEditingController _noteController = TextEditingController();

    // Show dialog with stateful widget content
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
  bool isQuestionIncluded = false; // State to track if the question is included

  @override
  void initState() {
    super.initState();
    saveButtonColor = widget.customColors.primary20;

    // Listen to changes in the TextField to update the button color
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
      child: SingleChildScrollView( // Make the dialog scrollable
        child: Container(
          padding: const EdgeInsets.all(16), // Padding inside the popup
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
                    maxLines: 2, // Limit to two lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Answer_Section_No_Title(
                controller: widget.noteController,
                customColors: widget.customColors,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isQuestionIncluded = !isQuestionIncluded; // Toggle the state
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isQuestionIncluded
                          ? widget.customColors.primary // Primary color when active
                          : widget.customColors.neutral80, // Neutral color when inactive
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '질문 포함',
                      style: body_xsmall(context).copyWith(
                        color: isQuestionIncluded
                            ? widget.customColors.primary // Match text color to state
                            : widget.customColors.neutral30,
                      ),
                    ),
                  ],
                ),
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
                          style: body_small_semi(context).copyWith(color: widget.customColors.neutral60),
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
                        onPressed: () {
                          final note = widget.noteController.text.trim();
                          if (note.isNotEmpty) {
                            debugPrint('메모 저장: $note');
                            debugPrint('질문 포함 상태: $isQuestionIncluded');
                          }

                          // Show customized SnackBar at the bottom
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: EdgeInsets.all(16),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: widget.customColors.neutral60.withOpacity(0.8), // Custom color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Ensure the width hugs content
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '메모가 저장되었어요.',
                                      style: body_small_semi(context).copyWith(color: widget.customColors.neutral100),
                                    ),
                                  ],
                                ),
                              ),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating, // To make it float and hug the content
                              backgroundColor: Colors.transparent, // Make the background transparent
                              elevation: 0, // Remove the default shadow (dim effect)
                              onVisible: () {
                                // Fade out effect using an animation
                                Future.delayed(Duration(seconds: 1), () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                });
                              },
                            ),
                          );

                          Navigator.pop(context); // Close the note dialog
                        },
                        child: Text(
                          '저장',
                          style: body_small_semi(context).copyWith(color: widget.customColors.neutral100),
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


  void _showWordOrSentencePopup(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (_isWordSelected(selectedText)) {
      _showWordPopup(context, selectedText);
    } else {
      _showSentencePopup(context, selectedText);
    }
  }

void _showWordPopup(BuildContext context, String selectedText) {
  final customColors = Theme.of(context).extension<CustomColors>()!;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16), // Adds horizontal margin
        child: Container(
          padding: const EdgeInsets.all(16), // Padding inside the popup
          decoration: ShapeDecoration(
            color: customColors.neutral100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and icon
                children: [
                  Text(
                    '해석',
                    style: body_small_semi(context).copyWith(
                      color: customColors.neutral30,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context), // Close dialog on click
                    icon: Icon(
                      Icons.close,
                      color: customColors.neutral30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedText,
                  style: body_small_semi(context).copyWith(
                    color: customColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: customColors.neutral90,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사전적 의미',
                      style: heading_xxsmall(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    Text(
                      '사전적 의미의 예시입니다.',
                      style: body_small(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '문맥상 의미',
                      style: heading_xxsmall(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    Text(
                      '문맥상 의미의 예시입니다.',
                      style: body_small(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '유사어',
                      style: heading_xxsmall(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    Text(
                      '유사어의 예시입니다.',
                      style: body_small(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '반의어',
                      style: heading_xxsmall(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    Text(
                      '반의어의 예시입니다.',
                      style: body_small(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}


  void _showSentencePopup(BuildContext context, String selectedText) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16), // Adds horizontal margin
          child: Container(
            padding: const EdgeInsets.all(16), // Padding inside the popup
            decoration: ShapeDecoration(
              color: customColors.neutral100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and icon
                  children: [
                    Text(
                      '해석',
                      style: body_small_semi(context).copyWith(
                        color: customColors.neutral30,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context), // Close dialog on click
                      icon: Icon(
                        Icons.close,
                        color: customColors.neutral30,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedText,
                    style: body_small_semi(context).copyWith(
                      color: customColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: customColors.neutral90,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '문맥상 의미',
                        style: heading_xxsmall(context).copyWith(
                          color: customColors.neutral30,
                        ),
                      ),
                      Text(
                        '문맥상 의미의 예시입니다.',
                        style: body_small(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '요약',
                        style: heading_xxsmall(context).copyWith(
                          color: customColors.neutral30,
                        ),
                      ),
                      Text(
                        '요약의 예시입니다.',
                        style: body_small(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isWordSelected(String selectedText) {
    return selectedText.split(' ').length == 1;
  }

  void _navigateToChatbot(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (selectedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBot(selectedText: selectedText),
        ),
      );
    }
  }
