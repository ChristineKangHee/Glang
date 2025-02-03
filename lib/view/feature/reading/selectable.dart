import 'package:flutter/material.dart';

class SelectableTextWithHighlight extends StatefulWidget {
  @override
  _SelectableTextWithHighlightState createState() => _SelectableTextWithHighlightState();
}

class _SelectableTextWithHighlightState extends State<SelectableTextWithHighlight> {
  List<TextSelection> _selections = []; // 여러 개의 선택 범위를 저장

  // 선택된 텍스트의 범위에 하이라이트 스타일 적용
  TextSpan _buildTextSpan(String text) {
    List<TextSpan> children = [];
    int start = 0;

    // 선택된 부분을 정렬하여 적용
    _selections.sort((a, b) => a.start.compareTo(b.start));

    for (var selection in _selections) {
      int selectionStart = selection.start;
      int selectionEnd = selection.end;

      if (selectionStart > start) {
        children.add(TextSpan(text: text.substring(start, selectionStart))); // 선택되지 않은 텍스트
      }

      children.add(TextSpan(
        text: text.substring(selectionStart, selectionEnd),
        style: TextStyle(backgroundColor: Colors.yellow.withOpacity(0.5)), // 하이라이트 스타일
      ));

      start = selectionEnd;
    }

    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start))); // 남은 일반 텍스트 추가
    }

    return TextSpan(children: children);
  }

  // 새로운 선택이 기존 하이라이트에 겹치는지 확인하는 함수
  bool _isOverlapping(TextSelection newSelection) {
    for (var selection in _selections) {
      if (!(newSelection.end <= selection.start || newSelection.start >= selection.end)) {
        return true; // 기존 하이라이트와 겹침
      }
    }
    return false; // 겹치지 않음
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selectable Text with Persistent Highlight")),
      body: Center(
        child: SelectableText.rich(
          _buildTextSpan('이 텍스트에서 일부를 선택하면 하이라이트됩니다.'),
          onSelectionChanged: (selection, cause) {
            setState(() {
              if (selection.start != selection.end && !_isOverlapping(selection)) {
                _selections.add(selection); // 기존 하이라이트와 겹치지 않으면 추가
              }
            });
          },
        ),
      ),
    );
  }
}
