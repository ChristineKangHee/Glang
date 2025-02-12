/// File: sentence_interpretation.dart
/// Purpose: 문장 해석(문맥상 의미 및 요약) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희 (원본 코드 참조)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 프로젝트 내 폰트/스타일 관련 함수 import (경로는 필요에 따라 수정)
import 'package:readventure/theme/font.dart';

/// ChatGPT API를 호출하여 문장 정보를 받아오는 함수
Future<Map<String, dynamic>> fetchSentenceDetails(String sentence, List<String> textSegments) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return {
      "contextualMeaning": "정보 없음",
      "summary": "정보 없음",
    };
  }

  const endpoint = 'https://api.openai.com/v1/chat/completions';
  final url = Uri.parse(endpoint);
  final String contextText = textSegments.join("\n");

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
            'You are a Korean text analysis assistant. For the given sentence, provide a JSON object with exactly the following keys: "contextualMeaning" and "summary". "contextualMeaning" should explain how the sentence is used in context based on the following text segments: "$contextText". "summary" should provide a concise summary of the sentence in Korean. If any information is not available, set its value to "정보 없음". 모든 결과는 한국어로 제공하세요. Return only the JSON object with no additional text.'
          },
          {
            'role': 'user',
            'content': 'Sentence: "$sentence"'
          },
        ],
        'max_tokens': 200,
        'temperature': 0.2,
        'n': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> resBody = jsonDecode(utf8.decode(response.bodyBytes));
      final String message = resBody["choices"][0]["message"]["content"];
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        return data;
      } catch (e) {
        print("ChatGPT 응답 파싱 실패: $e");
        return {
          "contextualMeaning": "정보 없음",
          "summary": "정보 없음",
        };
      }
    } else {
      print("ChatGPT API 호출 실패: ${response.statusCode} ${response.body}");
      return {
        "contextualMeaning": "정보 없음",
        "summary": "정보 없음",
      };
    }
  } catch (e) {
    print("Exception in fetchSentenceDetails: $e");
    return {
      "contextualMeaning": "정보 없음",
      "summary": "정보 없음",
    };
  }
}

/// 문장 해석 팝업 UI를 표시하는 함수
void showSentencePopup({
  required BuildContext context,
  required String selectedText,
  required List<String> textSegments,
  required dynamic customColors,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchSentenceDetails(selectedText, textSegments),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      '로딩 중...',
                      style: body_small_semi(context).copyWith(color: customColors.neutral30),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '오류가 발생했습니다.',
                      style: body_small_semi(context).copyWith(color: customColors.neutral30),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      snapshot.error.toString(),
                      style: body_small(context),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: customColors.neutral30,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final data = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 타이틀 및 닫기 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '해석',
                          style: body_small_semi(context).copyWith(color: customColors.neutral30),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: customColors.neutral30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 선택된 문장 표시
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedText,
                        style: body_small_semi(context).copyWith(color: customColors.primary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // API에서 받아온 결과 표시 (문맥상 의미 및 요약)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: customColors.neutral90,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '문맥상 의미',
                            style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
                          ),
                          Text(
                            data['contextualMeaning'] ?? '정보 없음',
                            style: body_small(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '요약',
                            style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
                          ),
                          Text(
                            data['summary'] ?? '정보 없음',
                            style: body_small(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
          },
        ),
      );
    },
  );
}
