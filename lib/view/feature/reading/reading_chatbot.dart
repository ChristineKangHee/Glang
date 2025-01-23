import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../api/reading_chatbot_service.dart';
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
  final List<Map<String, String>> _messages = [{'role': 'assistant', 'content': '어떤 도움이 필요하신가요?'}];
  final ChatBotService _chatBotService = ChatBotService();
  bool _isLoading = false;

  void _sendMessage() async {
    final message = _controller.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'content': message});
        _isLoading = true;
      });

      _controller.clear();

      try {
        final response = await _chatBotService.getChatResponse(widget.selectedText, _messages);
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
        });
      } catch (e) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': '오류가 발생했습니다: $e'});
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
            child: SingleChildScrollView(
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
                          '${widget.selectedText}',
                          style: body_small(context),
                        ),
                      ],
                    ),
                  ),
                  ..._messages.map((msg) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: msg['role'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg['role'] == 'user'
                              ? customColors.primary
                              : customColors.neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          msg['content']!,
                          style: body_small(context).copyWith(
                            color: msg['role'] == 'user'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
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

