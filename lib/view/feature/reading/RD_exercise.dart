import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readventure/view/feature/reading/reading_chatbot.dart';

// 사용자 정의 폰트 스타일, 색상, 컴포넌트 import
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../chat/chat_screen.dart';
import '../../components/my_divider.dart';

// Riverpod 상태 관리를 사용한 CustomSelectableText 위젯 정의
class CustomSelectableText extends ConsumerStatefulWidget {
  const CustomSelectableText({super.key});  // const 생성자는 성능 최적화를 위해 사용

  @override
  _CustomSelectableTextState createState() => _CustomSelectableTextState();
}

// CustomSelectableText 위젯의 상태 클래스 정의
class _CustomSelectableTextState extends ConsumerState<CustomSelectableText> {
  @override
  Widget build(BuildContext context) {
    // customColorsProvider에서 사용자 정의 색상 정보 가져오기
    final customColors = ref.watch(customColorsProvider);

    // MaterialApp과 Scaffold를 사용하여 기본 레이아웃 설정
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Text Selection')), // AppBar에 제목 추가
      body: Center(
        child: SelectableText(
          '드래그해서 선택하세요! 드래그 할 수 있는 많고 많은 텍스트들 한번 해봐라\n 으히히',
          selectionControls: RdMain(customColors: customColors), // 커스텀 선택 컨트롤 적용
          style: const TextStyle(fontSize: 20), // 텍스트 스타일 설정 (폰트 크기 20)
          cursorColor: customColors.primary, // 커서 색상을 사용자 정의 색상으로 설정
        ),
      ),
    );
  }
}

class RdMain extends MaterialTextSelectionControls {
  final customColors;

  RdMain({required this.customColors});

  @override
  void handleCopy(TextSelectionDelegate delegate) {
    final text = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    Clipboard.setData(ClipboardData(text: '커스텀 복사: $text'));
    delegate.bringIntoView(delegate.textEditingValue.selection.extent);
    delegate.hideToolbar();
  }

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
    const double toolbarPadding = 16.0;
    const double toolbarWidth = 180;

    final double toolbarX = (endpoints.first.point.dx + endpoints.last.point.dx) / 2
        - toolbarWidth / 2
        - globalEditableRegion.left;

    final double toolbarY = endpoints.first.point.dy
        + globalEditableRegion.top
        - toolbarHeight
        - toolbarPadding;

    final double toolbarXAdjusted = toolbarX < 0
        ? 0
        : (toolbarX + toolbarWidth > globalEditableRegion.width
        ? globalEditableRegion.width - toolbarWidth
        : toolbarX);

    final double toolbarYAdjusted = toolbarY < 0 ? 0 : toolbarY;

    return Stack(
      children: [
        Positioned(
          left: toolbarXAdjusted,
          top: toolbarYAdjusted,
          child: ToolBar(toolbarWidth, toolbarHeight, context, delegate),
        ),
      ],
    );
  }

  Widget ToolBar(double toolbarWidth, double toolbarHeight, BuildContext context, TextSelectionDelegate delegate) {
    return Container(
      width: toolbarWidth,
      height: toolbarHeight,
      decoration: BoxDecoration(
        color: customColors.neutral90,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 30,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),  // 수평 패딩을 줄임
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton(context, '밑줄', () {}, false, delegate),
          _buildToolbarButton(
            context,
            '메모',
                () {
              final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
              _showNoteDialog(context, selectedText);
            },
            false,
            delegate, // Pass delegate here
          ),
          _buildToolbarButton(context, '해석', () {}, false, delegate), // Pass delegate here
          _buildToolbarButton(context, '챗봇', () {}, true, delegate),  // 마지막 버튼, pass delegate here
        ],
      ),
    );
  }

  Widget _buildToolbarButton(BuildContext context, String label, VoidCallback onPressed, bool isLast, TextSelectionDelegate delegate) {
    return GestureDetector(
      onTap: () {
        if (label == '밑줄') {
          final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
          if (selectedText.isNotEmpty) {
            _highlightText(context, selectedText, delegate);
          }
        }
        if (label == '해석') {
          final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
          if (_isWordSelected(selectedText)) {
            _showWordPopup(context, selectedText);
          } else {
            _showSentencePopup(context, selectedText);
          }
        }
        if (label == '챗봇') {
          final String selectedText = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
          if (selectedText.isNotEmpty) {
            // Navigate to ChatScreen and pass the selected text
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBot(selectedText: selectedText),
              ),
            );
          }
        }
        onPressed();  // Invoke the passed callback after handling the "해석" logic
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: body_small_semi(context).copyWith(
              color: customColors.neutral0,
              decoration: TextDecoration.none,
            ),
          ),
          if (!isLast) VerticalDivider(),
        ],
      ),
    );
  }

  void _highlightText(BuildContext context, String selectedText, TextSelectionDelegate delegate) {
    final TextStyle highlightedStyle = TextStyle(
      color: Colors.yellow,
      backgroundColor: Colors.yellow.withOpacity(0.3),
      decoration: TextDecoration.underline, // Underline text
    );

    // This part assumes a custom method to update the text styling, or you can use a rich text controller
    final String updatedText = delegate.textEditingValue.text.replaceRange(
      delegate.textEditingValue.selection.start,
      delegate.textEditingValue.selection.end,
      selectedText,
    );

    // Notify UI changes using state management (e.g., setState, Riverpod, etc.)
  }

  void _showNoteDialog(BuildContext context, String selectedText) {
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('메모 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '밑줄 친 텍스트: $selectedText',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: '메모를 입력하세요...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final note = _noteController.text.trim();
                if (note.isNotEmpty) {
                  // 메모를 저장하거나 처리하는 로직 추가
                  debugPrint('메모 저장: $note');
                }
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showWordPopup(BuildContext context, String selectedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('단어 해석: $selectedText'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('사전적 의미: ...'),
              Text('문맥상 의미: ...'),
              Text('유사어: ...'),
              Text('반의어: ...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  bool _isWordSelected(String selectedText) {
    return selectedText.split(' ').length == 1;
  }

  void _showSentencePopup(BuildContext context, String selectedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('문장 해석: $selectedText'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('문맥상 의미: ...'),
              Text('요약: ...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
