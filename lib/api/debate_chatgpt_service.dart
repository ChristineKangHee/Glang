/// File: debate_chatgpt_service.dart
/// Purpose: OpenAI API를 활용하여 토론 주제에 대한 AI 응답을 생성하고, 대화 내역을 관리하는 서비스 클래스
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

/*
  Comment by 민준
  - 토론 프롬프트. 현재 3.5 사용하고 있지만, 추후 더 나은 모델으로 변환.
  - 프롬프트 엔지니어링도 개선 필요함. 성능 끌어올리기.
 */

import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수(.env 파일)에서 API 키를 로드하기 위한 패키지

/// DebateGPTService: OpenAI GPT API를 사용하여 토론 주제에 대한 AI 응답을 가져오는 서비스 클래스
class DebateGPTService {
  /// `.env` 파일에서 OpenAI API 키를 가져옴
  /// 환경 변수 `OPENAI_API_KEY`가 설정되지 않았을 경우 기본값으로 빈 문자열(`''`)을 반환
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// OpenAI GPT-3.5를 사용하여 토론 응답을 가져오는 메서드
  ///
  /// - [topic]: 토론 주제
  /// - [conversationHistory]: 기존 대화 내역 (이전 사용자 및 AI 메시지 목록)
  /// - [userInput]: 새롭게 사용자가 입력한 메시지
  /// - 반환 값: AI가 생성한 응답 문자열
  Future<String> getDebateResponse({
    required String topic,
    required List<Map<String, String>> conversationHistory,
    required String userInput,
  }) async {
    // API 키가 설정되지 않았을 경우 예외 발생
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    // OpenAI ChatGPT API의 엔드포인트 URL (GPT-4 또는 GPT-3.5 사용 가능)
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    /// OpenAI에 전달할 메시지 리스트 초기화
    /// 'system' 역할의 메시지를 통해 토론의 목적과 방향을 설정
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
        '당신은 "$topic"에 대한 토론에 참여하고 있습니다. 논리적이고 설득력 있게 주장을 펼치세요. '
            '그리고 답변 후 필요시 "너는 왜 그렇게 생각하니?"와 같이 사용자가 자신의 의견을 구체적으로 설명하도록 유도하는 질문을 포함하세요.'
      },
      // 토론 주제를 명확하게 설정하는 초기 메시지 (선택적)
      {
        'role': 'user',
        'content': 'Debate topic: $topic'
      },
    ];

    // 기존 대화 내역을 추가 (이전 AI와 사용자 간의 대화 저장)
    // 예: [{'role': 'user', 'content': '...'}, {'role': 'assistant', 'content': '...'}, ...]
    messages.addAll(conversationHistory);

    // 사용자의 새로운 입력 메시지를 추가
    messages.add({
      'role': 'user',
      'content': userInput,
    });

    try {
      // OpenAI API에 POST 요청을 보냄
      final response = await http.post(
        Uri.parse(endpoint), // API URL을 URI 형식으로 변환
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // JSON 요청임을 명시
          'Authorization': 'Bearer $apiKey', // API 인증을 위한 Bearer 토큰 포함
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // 사용할 GPT 모델 지정 (GPT-4로 변경 가능)
          'messages': messages, // 사용자 입력 및 기존 대화 내역 포함
          'max_tokens': 300, // 응답의 최대 토큰 수 (출력 길이 제한)
          'temperature': 0.7, // 창의성 조절 (낮을수록 보수적인 응답, 높을수록 창의적인 응답)
          'n': 1, // 생성할 응답 개수 (여기서는 1개)
        }),
      );

      // 응답이 성공적으로 도착했을 경우 (HTTP 상태 코드 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩 후 JSON 파싱
        return data['choices'][0]['message']['content'].trim(); // AI의 응답을 반환 (앞뒤 공백 제거)
      } else {
        // 오류 발생 시 상태 코드와 응답 본문을 출력하여 디버깅
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch debate response: ${response.body}');
      }
    } catch (e) {
      // 예기치 않은 오류 발생 시 콘솔에 출력하고 예외를 다시 던짐
      print('Request failed with error: $e');
      throw Exception('Failed to fetch debate response: $e');
    }
  }
}
