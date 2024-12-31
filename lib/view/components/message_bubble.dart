/// File: message_bubble.dart
/// Purpose: ChatGPT와 사용자 간의 채팅 인터페이스 중 채팅 말풍선 부분 컴포넌트
/// Author: 박민준
/// Created: 2024-12-31
/// Last Modified: 2024-12-31 by 박민준

import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isError;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blue[200]
              : isError
              ? Colors.red[200]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
