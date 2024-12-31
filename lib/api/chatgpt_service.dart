/// File: chatgpt_service.dart
/// Purpose: OpenAI API와의 통신을 통해 주어진 프롬프트에 대한 ChatGPT 응답을 가져오는 서비스 클래스
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-31 by 박민준

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> getResponse(String prompt) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    const endpoint = 'https://api.openai.com/v1/completions';
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': prompt,
        'max_tokens': 100,
        'temperature': 0.7,
        'n': 1,
        'stop': null,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to fetch response: ${response.body}');
    }
  }
}
