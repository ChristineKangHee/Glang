import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';

class ChatBot extends ConsumerStatefulWidget {
  final String selectedText;

  ChatBot({required this.selectedText});

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();

  // Example function for handling sending the message (implement your own logic here)
  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      // Handle sending the message, like making an API call or appending to a list
      print("Message sent: $message");
      _controller.clear(); // Clear the input after sending the message
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('챗봇')),
      backgroundColor: customColors.neutral90,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(  // Wrap the body with SingleChildScrollView to make it scrollable
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(color: customColors.neutral100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 문장',
                          style: body_small_semi(context),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '드래그한 텍스트: ${widget.selectedText}',
                          style: body_small(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("추후 업데이트 예정입니다.", style: body_large_semi(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: customColors.neutral100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 4,
                        minLines: 1,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "시간 내에 의견을 입력해주세요",
                          hintStyle: body_small(context).copyWith(
                            color: customColors.neutral60,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: customColors.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
