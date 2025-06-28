/// File: word_interpretation.dart
/// Purpose: 단어 해석(사전적 의미, 문맥상 의미, 유사어, 반의어) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희 (원본 코드 참조)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart'; // 추가


// 프로젝트 내 폰트/스타일 관련 함수 import (경로는 필요에 따라 수정)
import 'package:readventure/theme/font.dart';

import '../../../../viewmodel/bookmark_interpretation.dart';

/// 기본 응답 값 (API 호출 실패 시 반환)
const Map<String, dynamic> defaultResponse = {
  "dictionaryMeaning": "정보 없음",
  "contextualMeaning": "정보 없음",
  "synonyms": [],
  "antonyms": [],
};

/// shimmer 효과 위젯 반환 함수
Widget shimmerLine({
  required double width,
  required double height,
  Color color = Colors.white,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(width: width, height: height, color: color),
  );
}

/// ChatGPT API를 호출하여 단어 정보를 받아오는 함수
Future<Map<String, dynamic>> fetchWordDetails(String word, List<String> textSegments) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  if (apiKey.isEmpty) return defaultResponse;

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
            'You are a Korean dictionary assistant. For the given word, provide a JSON object with exactly the following keys: "dictionaryMeaning", "contextualMeaning", "synonyms", and "antonyms". "dictionaryMeaning" should be a brief definition of the word in Korean. "contextualMeaning" should explain, based on the following text segments: "$contextText", which among the dictionary definitions is intended in the given sentence, and provide a detailed explanation of that particular meaning. "synonyms" should be an array of similar words in Korean, and "antonyms" should be an array of opposite words in Korean. If any information is not available, set its value to "정보 없음". 모든 결과는 한국어로 제공하세요. Return only the JSON object with no additional text.'
          },
          {
            'role': 'user',
            'content': 'Word: "$word"'
          },
        ],
        'max_tokens': 300,
        'temperature': 0.2,
        'n': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> resBody = jsonDecode(utf8.decode(response.bodyBytes));
      final String message = resBody["choices"][0]["message"]["content"];
      try {
        return jsonDecode(message);
      } catch (e) {
        print("ChatGPT 응답 파싱 실패: $e");
        return defaultResponse;
      }
    } else {
      print("ChatGPT API 호출 실패: ${response.statusCode} ${response.body}");
      return defaultResponse;
    }
  } catch (e) {
    print("Exception in fetchWordDetails: $e");
    return defaultResponse;
  }
}

/// 팝업 상단 헤더 위젯 (타이틀 및 닫기, 북마크 아이콘 포함)
Widget _buildPopupHeader(
    BuildContext context,
    dynamic customColors, {
      required VoidCallback onClose,
      VoidCallback? onBookmark,
      required bool isBookmarked,
    }) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'interpretation_title'.tr(),
        style: body_small_semi(context).copyWith(color: customColors.neutral30),
      ),
      Row(
        children: [
          IconButton(
            onPressed: onBookmark,
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
              color: customColors.neutral30,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: customColors.neutral30),
          ),
        ],
      ),
    ],
  );
}

/// 선택된 단어 표시 위젯
Widget _buildSelectedWord(BuildContext context, String selectedText, dynamic customColors) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      selectedText,
      style: body_small_semi(context).copyWith(color: customColors.primary),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// 결과 내용 컨테이너 공통 위젯
Widget _buildResultContainer(Widget child, dynamic customColors) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: ShapeDecoration(
      color: customColors.neutral90,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: child,
  );
}

/// API 응답 결과를 표시하는 위젯
Widget _buildResultContent(BuildContext context, Map<String, dynamic> data, dynamic customColors) {
  final List<dynamic> synonyms = data['synonyms'] is List ? data['synonyms'] : [];
  final List<dynamic> antonyms = data['antonyms'] is List ? data['antonyms'] : [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'dictionary_meaning'.tr(),
        style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
      ),
      Text(
        data['dictionaryMeaning'] ?? 'info_not_available'.tr(),
        style: body_small(context),
      ),
      const SizedBox(height: 16),
      Text(
        'contextual_meaning'.tr(),
        style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
      ),
      Text(
        data['contextualMeaning'] ?? 'info_not_available'.tr(),
        style: body_small(context),
      ),
      const SizedBox(height: 16),
      Text(
        'synonyms'.tr(),
        style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
      ),
      Text(
        synonyms.isNotEmpty ? synonyms.join(', ') : 'info_not_available'.tr(),
        style: body_small(context),
      ),
      const SizedBox(height: 16),
      Text(
        'antonyms'.tr(),
        style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
      ),
      Text(
        antonyms.isNotEmpty ? antonyms.join(', ') : 'info_not_available'.tr(),
        style: body_small(context),
      ),
    ],
  );
}

/// 로딩 시 shimmer 효과로 API 결과 영역을 표시하는 위젯
Widget _buildLoadingContent(BuildContext context, dynamic customColors) {
  return _buildResultContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 사전적 의미
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        // 문맥상 의미
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        // 유사어
        shimmerLine(width: 60, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        // 반의어
        shimmerLine(width: 60, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
      ],
    ),
    customColors,
  );
}

/// 단어 해석 팝업 UI를 표시하는 함수
void showWordPopup({
  required BuildContext context,
  required String selectedText,
  required List<String> textSegments,
  required dynamic customColors,
  required String stageId,
  required String subdetailTitle,
}) {
  // Future를 한 번만 생성해서 재사용합니다.
  final futureData = fetchWordDetails(selectedText, textSegments);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      bool isBookmarked = false;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<Map<String, dynamic>>(
              future: futureData, // setState 호출 시 재생성되지 않습니다.
              builder: (context, snapshot) {
                Widget content;
                VoidCallback? onBookmarkCallback;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  onBookmarkCallback = null;
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPopupHeader(
                        context,
                        customColors,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      _buildSelectedWord(context, selectedText, customColors),
                      const SizedBox(height: 20),
                      _buildLoadingContent(context, customColors),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (snapshot.hasError) {
                  onBookmarkCallback = null;
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'error_occurred'.tr(),
                        style: body_small_semi(context).copyWith(color: customColors.neutral30),
                      ),
                      const SizedBox(height: 20),
                      Text(snapshot.error.toString(), style: body_small(context)),
                      const SizedBox(height: 20),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: customColors.neutral30),
                      ),
                    ],
                  );
                } else {
                  final data = snapshot.data!;
                  onBookmarkCallback = () async {
                    await saveBookmarkInterpretation(
                      stageId: stageId,
                      subdetailTitle: subdetailTitle,
                      selectedText: selectedText,
                      interpretationData: data,
                    );
                    setState(() {
                      isBookmarked = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("interpretation_saved".tr())),
                    );
                  };

                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPopupHeader(
                        context,
                        customColors,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      _buildSelectedWord(context, selectedText, customColors),
                      const SizedBox(height: 20),
                      _buildResultContainer(
                        _buildResultContent(context, data, customColors),
                        customColors,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: content,
                );
              },
            );
          },
        ),
      );
    },
  );
}
