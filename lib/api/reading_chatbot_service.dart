/// File: reading_chatbot_service.dart
/// Purpose: OpenAI API를 이용하여 읽기 중 활동 간 AI 응답을 생성하는 서비스 클래스
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

/*
  Comment by 민준
  - 읽기 중 활동 중 사용된다. 선택해서 보내진 텍스트를 기반으로 지룬에 응답.
 */


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatBotService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> getChatResponse(
      String selectedText,
      List<String> textSegments,
      List<Map<String, String>> messages,
      ) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': 'Selected text: $selectedText'},
            // Add context from textSegments
            {'role': 'user', 'content': 'Context: ${textSegments.join(" ")}'},
            ...messages,
            // 추가된 프롬프트 지시: 4문장으로 답변
            {'role': 'user', 'content': 'Please provide your answer in 4 sentences or less.'},
          ],
          'max_tokens': 300,
          'temperature': 0.7,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String responseContent = data['choices'][0]['message']['content'].trim();

        return responseContent;
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch chat response: ${response.body}');
      }
    } catch (e) {
      print('Request failed with error: $e');
      throw Exception('Failed to fetch chat response: $e');
    }
  }
}
