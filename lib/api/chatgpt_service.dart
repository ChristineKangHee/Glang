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
