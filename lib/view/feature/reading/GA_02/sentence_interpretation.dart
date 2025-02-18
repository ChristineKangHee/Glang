/// File: sentence_interpretation.dart
/// Purpose: 문장 해석(문맥상 의미 및 요약) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readventure/theme/font.dart';

/// ChatGPT API를 호출하여 문장 정보를 받아오는 함수
Future<Map<String, dynamic>> fetchSentenceDetails(String sentence, List<String> textSegments) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return {"contextualMeaning": "정보 없음", "summary": "정보 없음"};
  }

  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final contextText = textSegments.join("\n");

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
            'content': 'You are a Korean text analysis assistant. For the given sentence, provide a JSON object with "contextualMeaning" and "summary". "contextualMeaning" should explain how the sentence is used in context based on: "$contextText". "summary" should summarize the sentence in Korean. If unavailable, return "정보 없음".'
          },
          {'role': 'user', 'content': 'Sentence: "$sentence"'}
        ],
        'max_tokens': 200,
        'temperature': 0.2,
        'n': 1,
      }),
    );

    if (response.statusCode == 200) {
      final resBody = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonDecode(resBody["choices"][0]["message"]["content"] ?? '{}') ??
          {"contextualMeaning": "정보 없음", "summary": "정보 없음"};
    } else {
      return {"contextualMeaning": "정보 없음", "summary": "정보 없음"};
    }
  } catch (_) {
    return {"contextualMeaning": "정보 없음", "summary": "정보 없음"};
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
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchSentenceDetails(selectedText, textSegments),
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.connectionState == ConnectionState.waiting) {
            content = _loadingState(customColors, selectedText, context);
          } else if (snapshot.hasError) {
            content = _errorState(snapshot.error.toString(), customColors, context);
          } else {
            content = _resultState(snapshot.data!, customColors, selectedText, context);
          }
          return Container(padding: const EdgeInsets.all(16), child: content);
        },
      ),
    ),
  );
}

/// 로딩 상태: 문맥상 의미와 요약 각각에 shimmer 표시
Widget _loadingState(dynamic customColors, String selectedText, BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _popupHeader(customColors, context),
      _selectedTextWidget(selectedText, customColors, context),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: customColors.neutral90,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 문맥상 의미 영역 shimmer
            _shimmerPlaceholder(),
            const SizedBox(height: 16),
            // 요약 영역 shimmer
            _shimmerPlaceholder(),
          ],
        ),
      ),
    ],
  );
}

/// shimmer placeholder 위젯 (제목과 내용 모양)
Widget _shimmerPlaceholder() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 제목 자리 shimmer
      Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 16,
          width: 80,
          color: Colors.grey.shade300,
        ),
      ),
      const SizedBox(height: 8),
      // 내용 자리 shimmer
      Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 14,
          width: double.infinity,
          color: Colors.grey.shade300,
        ),
      ),
    ],
  );
}

Widget _errorState(String error, dynamic customColors, BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _popupHeader(customColors, context),
      const SizedBox(height: 20),
      Text('오류가 발생했습니다.', style: body_small_semi(context).copyWith(color: customColors.neutral30)),
      const SizedBox(height: 10),
      Text(error, style: body_small(context)),
    ],
  );
}

Widget _resultState(Map<String, dynamic> data, dynamic customColors, String selectedText, BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _popupHeader(customColors, context),
      _selectedTextWidget(selectedText, customColors, context),
      const SizedBox(height: 20),
      _resultContainer(data, customColors, context),
    ],
  );
}

Widget _popupHeader(dynamic customColors, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('해석', style: body_small_semi(context).copyWith(color: customColors.neutral30)),
      Row(
        children: [
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.bookmark_border, color: customColors.neutral30),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: customColors.neutral30),
          ),
        ],
      ),
    ],
  );
}

Widget _selectedTextWidget(String selectedText, dynamic customColors, BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      selectedText,
      style: body_small_semi(context).copyWith(color: customColors.primary),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    ),
  );
}

Widget _resultContainer(Map<String, dynamic> data, dynamic customColors, BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: customColors.neutral90,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resultText('문맥상 의미', data['contextualMeaning'] ?? '정보 없음', customColors, context),
        const SizedBox(height: 16),
        _resultText('요약', data['summary'] ?? '정보 없음', customColors, context),
      ],
    ),
  );
}

Widget _resultText(String title, String content, dynamic customColors, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(content, style: body_small(context)),
    ],
  );
}
