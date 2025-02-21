/// File: chatgpt_service.dart
/// Purpose: OpenAI API와 통신하여 주어진 프롬프트에 대한 ChatGPT 응답을 가져오는 서비스 클래스
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-31 by 박민준

/*
  Comment by 민준
  - ChatGPT 서비스의 예시 코드. 실 사용은 없지만 이 코드 베이스로 다른 챗봇 서비스 기획하면 됩니다.
 */

import 'dart:convert'; // JSON 데이터 인코딩 및 디코딩을 위해 사용
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수(.env 파일)에서 API 키를 로드하기 위한 패키지

class ChatGPTService {
  /// OpenAI API 키를 환경 변수에서 가져옴
  /// `.env` 파일에서 `OPENAI_API_KEY` 값을 읽어옴
  /// 만약 값이 없으면 빈 문자열(`''`)을 기본값으로 설정
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// ChatGPT API를 호출하여 사용자의 입력(prompt)에 대한 응답을 가져오는 비동기 함수
  ///
  /// - [prompt]: 사용자가 ChatGPT에 보낼 질문 또는 요청
  /// - 반환 값: AI가 생성한 응답 문자열
  Future<String> getResponse(String prompt) async {
    // API 키가 설정되지 않은 경우 예외(Exception) 발생
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file.');
    }

    // OpenAI ChatGPT API의 엔드포인트 URL
    const endpoint = 'https://api.openai.com/v1/completions';

    // OpenAI API에 POST 요청을 보냄
    final response = await http.post(
      Uri.parse(endpoint), // API의 URL을 URI 형식으로 변환
      headers: {
        'Content-Type': 'application/json', // 요청 본문이 JSON 형식임을 지정
        'Authorization': 'Bearer $apiKey', // API 인증을 위한 Bearer 토큰 포함
      },
      body: jsonEncode({
        'model': 'text-davinci-003', // 사용할 OpenAI 모델 지정 (GPT-3.5 기반)
        'prompt': prompt, // 사용자 입력(질문 또는 요청)
        'max_tokens': 100, // 응답의 최대 토큰 수 (출력 길이 제한)
        'temperature': 0.7, // 창의성 조절 (낮을수록 보수적인 응답, 높을수록 창의적인 응답)
        'n': 1, // 생성할 응답 개수 (여기서는 1개)
        'stop': null, // 응답을 중단할 특정 문자열 (null이면 끝까지 생성)
      }),
    );

    // 응답 코드가 200(성공)일 경우, 결과를 JSON으로 파싱하여 응답 텍스트 반환
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // JSON 응답을 Dart 객체로 변환
      return data['choices'][0]['text'].trim(); // ChatGPT의 응답을 반환 (앞뒤 공백 제거)
    } else {
      // 요청 실패 시 예외(Exception) 발생 (실패 원인을 응답 본문에서 가져옴)
      throw Exception('Failed to fetch response: ${response.body}');
    }
  }
}
