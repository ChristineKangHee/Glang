import 'package:flutter/material.dart';

import '../../../theme/font.dart';

class ChatBot extends StatelessWidget {
  final String selectedText;

  const ChatBot({super.key, required this.selectedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('챗봇')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('드래그한 텍스트: $selectedText'),
            // Add chatbot UI here, such as an input field and chat history
            Text("추후 업데이트 예정입니다.", style: body_large_semi(context),)
          ],
        ),
      ),
    );
  }
}
