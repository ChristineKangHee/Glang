import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DebateGPTService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// conversationHistory: 기존 대화 내역 (예: [{'role': 'user', 'content': '...'}, ...])
  /// userInput: 새롭게 사용자가 입력한 메시지
  /// topic: 토론 주제
  Future<String> getDebateResponse({
    required String topic,
    required List<Map<String, String>> conversationHistory,
    required String userInput,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';

    // 새로운 대화 내역 구성: 개선된 시스템 프롬프트를 통해 유도 질문 포함
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
        '당신은 "$topic"에 대한 토론에 참여하고 있습니다. 논리적이고 설득력 있게 주장을 펼치세요. '
            '그리고 답변 후 필요시 "너는 왜 그렇게 생각하니?"와 같이 사용자가 자신의 의견을 구체적으로 설명하도록 유도하는 질문을 포함하세요.'

      },
      // 토론 주제에 대한 초기 컨텍스트를 전달 (필요에 따라 유지 또는 제거 가능)
      {
        'role': 'user',
        'content': 'Debate topic: $topic'
      },
    ];

    // 기존 대화 내역을 추가 (에러나 기타 특수 메시지는 필터링할 수도 있음)
    messages.addAll(conversationHistory);

    // 새롭게 사용자의 메시지 추가
    messages.add({
      'role': 'user',
      'content': userInput,
    });

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
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
        throw Exception('Failed to fetch debate response: ${response.body}');
      }
    } catch (e) {
      print('Request failed with error: $e');
      throw Exception('Failed to fetch debate response: $e');
    }
  }
}
