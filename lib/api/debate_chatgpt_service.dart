import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DebateGPTService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> getDebateResponse(String topic, String userInput) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // UTF-8 인코딩 설정
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
              'You are participating in a debate. Stay focused on the topic and provide clear and logical arguments.'
            },
            {'role': 'user', 'content': 'Debate topic: $topic'},
            {'role': 'user', 'content': userInput},
          ],
          'max_tokens': 200,
          'temperature': 0.7,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        return data['choices'][0]['message']['content'].trim();
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch debate response: ${response.body}');
      }
    } catch (e) {
      print('Request failed with error: $e');
      throw Exception('Failed to fetch debate response: $e');
    }
  }
}
