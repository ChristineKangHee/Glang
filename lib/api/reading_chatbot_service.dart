import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ChatBotService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> getChatResponse(
      String selectedText, List<Map<String, String>> messages) async {
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
            ...messages,
          ],
          'max_tokens': 300,
          'temperature': 0.7,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].trim();
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
