/// File: sentence_interpretation.dart
/// Purpose: 문장 해석(문맥상 의미 및 요약) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희
/// Last Modified: 2025-10-02 by ChatGPT (JSON 강제/파싱 보정/안정화)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readventure/theme/font.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../viewmodel/bookmark_interpretation.dart';

/// 공통 기본 응답
const Map<String, dynamic> _defaultSentenceResponse = {
  "contextualMeaning": "정보 없음",
  "summary": "정보 없음",
};

/// ChatGPT API를 호출하여 문장 정보를 받아오는 함수 (안정화 버전)
Future<Map<String, dynamic>> fetchSentenceDetails(
    String sentence,
    List<String> textSegments,
    ) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    debugPrint('[sentence] OPENAI_API_KEY empty');
    return _defaultSentenceResponse;
  }

  final trimmedSentence = sentence.trim();
  if (trimmedSentence.isEmpty) {
    debugPrint('[sentence] Selected sentence is empty');
    return _defaultSentenceResponse;
  }

  const endpoint = 'https://api.openai.com/v1/chat/completions';
  final url = Uri.parse(endpoint);

  // 문맥 과다 길이 방지 (토큰 압박 완화)
  final String contextText = textSegments.join("\n");
  final String clippedContext =
  contextText.length > 4000 ? contextText.substring(0, 4000) : contextText;

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
        // ✅ JSON만 오도록 강제
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
            '당신은 한국어 텍스트 분석 도우미입니다. 반드시 JSON 객체 하나만 반환하세요. '
                '키는 정확히 contextualMeaning, summary. '
                'contextualMeaning은 제공된 문맥에 근거해 문장이 담는 의미/의도를 한국어로 설명하고, '
                'summary는 해당 문장을 한국어로 간결히 요약하세요. '
                '모르면 "정보 없음"을 사용하세요. JSON 외 텍스트 금지.'
          },
          {
            'role': 'user',
            'content':
            '문맥 세그먼트:\n$clippedContext\n\n문장: "$trimmedSentence"\nJSON만 반환하세요.'
          },
        ],
        'temperature': 0.2,
        // ✅ 잘림 방지 (여유 확보)
        'max_tokens': 600,
        'n': 1,
      }),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resBody = jsonDecode(utf8.decode(response.bodyBytes));
      final dynamic content = resBody['choices']?[0]?['message']?['content'];
      final String raw = (content ?? '').toString();

      // 혹시 코드펜스/잡텍스트가 와도 첫 번째 JSON 객체만 추출
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
        debugPrint('[sentence] No JSON object found in response: $raw');
        return _defaultSentenceResponse;
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(jsonStr);
      } catch (e) {
        debugPrint('[sentence] JSON decode failed: $e\n$jsonStr');
        return _defaultSentenceResponse;
      }

      return {
        'contextualMeaning': parsed['contextualMeaning'] ?? '정보 없음',
        'summary': parsed['summary'] ?? '정보 없음',
      };
    } else {
      debugPrint('[sentence] OpenAI error ${response.statusCode}: ${response.body}');
      return _defaultSentenceResponse;
    }
  } catch (e, st) {
    debugPrint('[sentence] Exception: $e\n$st');
    return _defaultSentenceResponse;
  }
}

/// shimmer 효과 위젯 (단순 선 형태)
Widget shimmerLine({
  required double width,
  required double height,
  Color? color,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(width: width, height: height, color: color ?? Colors.grey.shade300),
  );
}

/// 팝업 상단 헤더 위젯 (타이틀, 북마크, 닫기 버튼 포함)
Widget _popupHeader(
    dynamic customColors,
    BuildContext context, {
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

/// 선택된 문장 표시 위젯
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

/// 로딩 시 표시할 내용 (문맥상 의미와 요약 각각 shimmer 효과)
Widget _buildLoadingContent(dynamic customColors, BuildContext context) {
  return _buildResultContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 문맥상 의미 shimmer
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 14),
        const SizedBox(height: 16),
        // 요약 shimmer
        shimmerLine(width: 60, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 14),
      ],
    ),
    customColors,
    context,
  );
}

/// API 응답 결과를 위젯으로 표시 (문맥상 의미와 요약)
Widget _buildResultContent(Map<String, dynamic> data, dynamic customColors, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('contextual_meaning'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(data['contextualMeaning'] ?? 'info_not_available'.tr(), style: body_small(context)),
      const SizedBox(height: 16),
      Text('summary'.tr(),
          style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(data['summary'] ?? 'info_not_available'.tr(), style: body_small(context)),
    ],
  );
}

/// 결과 내용 컨테이너 (공통 UI)
Widget _buildResultContainer(Widget child, dynamic customColors, BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: customColors.neutral90,
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}

/// 문장 해석 팝업 UI를 표시하는 함수
/// (stageId, subdetailTitle을 추가하여 북마크 저장 시 함께 사용)
void showSentencePopup({
  required BuildContext context,
  required String selectedText,
  required List<String> textSegments,
  required dynamic customColors,
  required String stageId,
  required String subdetailTitle,
}) {
  // 빈 선택 방어
  final trimmed = selectedText.trim();
  if (trimmed.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('info_not_available'.tr())),
    );
    return;
  }

  // Future를 한 번만 생성하여 재사용
  final futureData = fetchSentenceDetails(trimmed, textSegments);

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
                      _popupHeader(
                        customColors,
                        context,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      _selectedTextWidget(trimmed, customColors, context),
                      const SizedBox(height: 20),
                      _buildLoadingContent(customColors, context),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (snapshot.hasError) {
                  onBookmarkCallback = null;
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _popupHeader(
                        customColors,
                        context,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'error_occurred'.tr(),
                        style: body_small_semi(context).copyWith(color: customColors.neutral30),
                      ),
                      const SizedBox(height: 10),
                      Text(snapshot.error.toString(), style: body_small(context)),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  final data = snapshot.data ?? _defaultSentenceResponse;

                  onBookmarkCallback = () async {
                    await saveBookmarkSentenceInterpretation(
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
                      _popupHeader(
                        customColors,
                        context,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      _selectedTextWidget(trimmed, customColors, context),
                      const SizedBox(height: 20),
                      _buildResultContainer(
                        _buildResultContent(data, customColors, context),
                        customColors,
                        context,
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
