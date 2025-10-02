/// File: word_interpretation.dart
/// Purpose: 단어 해석(사전적 의미, 문맥상 의미, 유사어, 반의어) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희 (원본 코드 참조)
/// Last Modified: 2025-10-02 by ChatGPT (JSON 강제/파싱 보정/안정화)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

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

/// shimmer 효과 위젯
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

/// ChatGPT API를 호출하여 단어 정보를 받아오는 함수 (안정화 버전)
Future<Map<String, dynamic>> fetchWordDetails(String word, List<String> textSegments) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    debugPrint('[word] OPENAI_API_KEY empty');
    return defaultResponse;
  }

  const endpoint = 'https://api.openai.com/v1/chat/completions';
  final url = Uri.parse(endpoint);

  // 문맥 과다 길이 방지 (토큰 압박 완화)
  final String contextText = textSegments.join("\n");
  final String clippedContext =
  contextText.length > 4000 ? contextText.substring(0, 4000) : contextText;

  // 선택 단어 방어
  final String trimmedWord = word.trim();
  if (trimmedWord.isEmpty) {
    debugPrint('[word] Selected word is empty');
    return defaultResponse;
  }

  try {
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        // ✅ JSON만 오게 강제
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
            '당신은 한국어 사전 도우미입니다. 아래 JSON 스키마대로만 반환하세요. '
                '키는 정확히 dictionaryMeaning, contextualMeaning, synonyms, antonyms. '
                '모든 결과는 한국어. contextualMeaning은 주어진 문맥에 근거해 가장 적절한 의미를 상세히 설명. '
                'synonyms/antonyms는 문자열 배열. 모르면 "정보 없음". JSON 외 텍스트 금지.'
          },
          {
            'role': 'user',
            'content':
            '문맥 세그먼트:\n$clippedContext\n\n단어: "$trimmedWord"\nJSON만 반환하세요.'
          },
        ],
        'temperature': 0.2,
        // ✅ 잘림 방지 (여유 확보)
        'max_tokens': 800,
        'n': 1,
      }),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resBody = jsonDecode(utf8.decode(response.bodyBytes));
      final dynamic content = resBody['choices']?[0]?['message']?['content'];
      final String raw = (content ?? '').toString();

      // 혹시 모를 코드펜스/잡텍스트가 와도 첫 번째 JSON 객체만 추출
      String extractJsonObject(String s) {
        final start = s.indexOf('{');
        if (start < 0) return '';
        int depth = 0;
        for (int i = start; i < s.length; i++) {
          final ch = s[i];
          if (ch == '{') depth++;
          if (ch == '}') {
            depth--;
            if (depth == 0) {
              return s.substring(start, i + 1);
            }
          }
        }
        return '';
      }

      final jsonStr = extractJsonObject(raw);
      if (jsonStr.isEmpty) {
        debugPrint('[word] No JSON object found in response: $raw');
        return defaultResponse;
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(jsonStr);
      } catch (e) {
        debugPrint('[word] JSON decode failed: $e\n$jsonStr');
        return defaultResponse;
      }

      // 방어적 캐스팅/기본값 보정
      return {
        'dictionaryMeaning': parsed['dictionaryMeaning'] ?? '정보 없음',
        'contextualMeaning': parsed['contextualMeaning'] ?? '정보 없음',
        'synonyms': (parsed['synonyms'] is List)
            ? List<String>.from(parsed['synonyms'])
            : <String>[],
        'antonyms': (parsed['antonyms'] is List)
            ? List<String>.from(parsed['antonyms'])
            : <String>[],
      };
    } else {
      debugPrint('[word] OpenAI error ${response.statusCode}: ${response.body}');
      return defaultResponse;
    }
  } catch (e, st) {
    debugPrint('[word] Exception: $e\n$st');
    return defaultResponse;
  }
}

/// 팝업 상단 헤더 (타이틀/닫기/북마크)
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

/// 선택된 단어 표시
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

/// 결과 컨테이너 공통
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

/// API 응답 결과 UI
Widget _buildResultContent(BuildContext context, Map<String, dynamic> data, dynamic customColors) {
  final List<dynamic> synonyms = data['synonyms'] is List ? data['synonyms'] : [];
  final List<dynamic> antonyms = data['antonyms'] is List ? data['antonyms'] : [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('dictionary_meaning'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(data['dictionaryMeaning'] ?? 'info_not_available'.tr(), style: body_small(context)),
      const SizedBox(height: 16),
      Text('contextual_meaning'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(data['contextualMeaning'] ?? 'info_not_available'.tr(), style: body_small(context)),
      const SizedBox(height: 16),
      Text('synonyms'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(synonyms.isNotEmpty ? synonyms.join(', ') : 'info_not_available'.tr(),
          style: body_small(context)),
      const SizedBox(height: 16),
      Text('antonyms'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(antonyms.isNotEmpty ? antonyms.join(', ') : 'info_not_available'.tr(),
          style: body_small(context)),
    ],
  );
}

/// 로딩 시 shimmer
Widget _buildLoadingContent(BuildContext context, dynamic customColors) {
  return _buildResultContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        shimmerLine(width: 60, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
        const SizedBox(height: 16),
        shimmerLine(width: 60, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 16),
      ],
    ),
    customColors,
  );
}

/// 단어 해석 팝업 표시
void showWordPopup({
  required BuildContext context,
  required String selectedText,
  required List<String> textSegments,
  required dynamic customColors,
  required String stageId,
  required String subdetailTitle,
}) {
  // 빈 선택 단어 방어
  final String trimmed = selectedText.trim();
  if (trimmed.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('info_not_available'.tr())),
    );
    return;
  }

  // Future를 한 번만 생성해서 재사용
  final futureData = fetchWordDetails(trimmed, textSegments);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      bool isBookmarked = false;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<Map<String, dynamic>>(
              future: futureData,
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
                      _buildSelectedWord(context, trimmed, customColors),
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
                      _buildPopupHeader(
                        context,
                        customColors,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'error_occurred'.tr(),
                        style: body_small_semi(context).copyWith(color: customColors.neutral30),
                      ),
                      const SizedBox(height: 12),
                      Text(snapshot.error.toString(), style: body_small(context)),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  final data = snapshot.data ?? defaultResponse;

                  onBookmarkCallback = () async {
                    await saveBookmarkInterpretation(
                      stageId: stageId,
                      subdetailTitle: subdetailTitle,
                      selectedText: trimmed,
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
                      _buildSelectedWord(context, trimmed, customColors),
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
