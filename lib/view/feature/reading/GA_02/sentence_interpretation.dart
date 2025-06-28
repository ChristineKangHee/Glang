/// File: sentence_interpretation.dart
/// Purpose: 문장 해석(문맥상 의미 및 요약) 관련 API 호출 및 팝업 UI 처리
/// Author: 강희

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readventure/theme/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // 추가
import '../../../../viewmodel/bookmark_interpretation.dart';

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
      Text('interpretation_title'.tr(), style: body_small_semi(context).copyWith(color: customColors.neutral30)),
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
        // 문맥상 의미 shimmer (제목 + 내용)
        shimmerLine(width: 80, height: 16),
        const SizedBox(height: 8),
        shimmerLine(width: double.infinity, height: 14),
        const SizedBox(height: 16),
        // 요약 shimmer (제목 + 내용)
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
      Text('contextual_meaning'.tr(), style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
      Text(data['contextualMeaning'] ?? 'info_not_available'.tr(), style: body_small(context)),
      const SizedBox(height: 16),
      Text('summary'.tr(), style: heading_xxsmall(context).copyWith(color: customColors.neutral30)),
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
  // Future를 한 번만 생성하여 재사용
  final futureData = fetchSentenceDetails(selectedText, textSegments);

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
                      _selectedTextWidget(selectedText, customColors, context),
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
                      Text('error_occurred'.tr(), style: body_small_semi(context).copyWith(color: customColors.neutral30)),
                      const SizedBox(height: 10),
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
                    await saveBookmarkSentenceInterpretation(
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
                      _popupHeader(
                        customColors,
                        context,
                        onClose: () => Navigator.pop(context),
                        onBookmark: onBookmarkCallback,
                        isBookmarked: isBookmarked,
                      ),
                      const SizedBox(height: 20),
                      _selectedTextWidget(selectedText, customColors, context),
                      const SizedBox(height: 20),
                      _buildResultContainer(_buildResultContent(data, customColors, context), customColors, context),
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
