/// File: chat_screen.dart
/// Purpose: ChatGPT와 사용자 간의 채팅 인터페이스를 제공하여 메시지를 주고받을 수 있는 화면 구현
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-31 by 박민준

import 'package:flutter/material.dart';
import '../../api/chatgpt_service.dart';
import '../components/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatGPTService _chatService = ChatGPTService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // 채팅 메시지 저장

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': userMessage}); // 사용자 메시지 추가
    });

    _controller.clear();

    try {
      final response = await _chatService.getResponse(userMessage);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response}); // AI 응답 추가
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'error', 'content': 'Failed to get a response.'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                final isError = message['role'] == 'error';

                return MessageBubble(
                  content: message['content'] ?? '',
                  isUser: isUser,
                  isError: isError,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
