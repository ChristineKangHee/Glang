import 'package:flutter/material.dart';

class TextHighlight extends StatefulWidget {
  @override
  _TextHighlightState createState() => _TextHighlightState();
}

class _TextHighlightState extends State<TextHighlight> {
  String _selectedText = '';
  bool _isHighlighted = false;

  void _toggleHighlight() {
    setState(() {
      _isHighlighted = !_isHighlighted;
    });
  }

  @override
  Widget build(BuildContext context) {
    String text = '이 텍스트를 드래그하여 밑줄이나 하이라이트를 적용할 수 있습니다.';

    return Scaffold(
      appBar: AppBar(title: Text('텍스트 밑줄 및 하이라이트')),
      body: Column(
        children: [
          SelectableText(
            text,
            style: TextStyle(
              fontSize: 20,
              backgroundColor: _isHighlighted ? Colors.yellow : null, // 하이라이트 색상
            ),
            onSelectionChanged: (selection, cause) {
              setState(() {
                // 텍스트 선택 후, 선택된 부분을 표시
                _selectedText = selection.textInside(text);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleHighlight,
                child: Text('하이라이트'),
              ),
            ],
          ),
          Text('선택된 텍스트: $_selectedText'),
        ],
      ),
    );
  }
}
