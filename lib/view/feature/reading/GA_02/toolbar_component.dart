/// File: toolbar_component.dart
/// Purpose: 읽기 중 드래그 후 나타나는 툴바 및 단어/문장 해석 팝업 처리
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 (수정: ChatGPT API 연동 및 DebateGPTService 참고)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../theme/theme.dart';
import 'reading_chatbot.dart';
import '../../../../theme/font.dart';
import '../../after_read/widget/answer_section.dart';
// ReadingData의 경로에 맞게 import 수정
import 'package:readventure/model/reading_data.dart';

class Toolbar extends StatefulWidget {
  final double toolbarWidth;
  final double toolbarHeight;
  final BuildContext context;
  final TextSelectionDelegate delegate;
  final customColors;
  final ReadingData readingData; // 추가: 현재 읽기 데이터를 전달

  const Toolbar({
    Key? key,
    required this.toolbarWidth,
    required this.toolbarHeight,
    required this.context,
    required this.delegate,
    required this.customColors,
    required this.readingData,
  }) : super(key: key);

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.toolbarWidth,
      height: widget.toolbarHeight,
      decoration: BoxDecoration(
        color: widget.customColors.neutral90,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 30,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton('메모', () => _showNoteDialog(context, widget.delegate), false),
          _buildToolbarButton('해석', () => _showWordOrSentencePopup(context, widget.delegate), false),
          _buildToolbarButton('챗봇', () => _navigateToChatbot(context, widget.delegate), true),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed, bool isLast) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: body_small_semi(context).copyWith(
              color: widget.customColors.neutral0,
              decoration: TextDecoration.none,
            ),
          ),
          if (!isLast)
            VerticalDivider(
              color: widget.customColors.neutral60,
            ),
        ],
      ),
    );
  }

  void _highlightText(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (selectedText.isNotEmpty) {
      final TextStyle highlightedStyle = TextStyle(
        color: Colors.yellow,
        backgroundColor: Colors.yellow.withOpacity(0.3),
        decoration: TextDecoration.underline,
      );
      // 하이라이트 적용 로직 추가 가능
    }
  }

  void _showNoteDialog(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _NoteDialog(
          selectedText: selectedText,
          noteController: _noteController,
          customColors: widget.customColors,
        );
      },
    );
  }

  /// ChatGPT API를 호출하여 단어 정보를 받아오는 함수
  /// [textSegments]를 참조하여 문맥상 의미를 산출하며, 모든 결과는 한국어로 제공합니다.
  Future<Map<String, dynamic>> _fetchWordDetails(String word, List<String> textSegments) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API Key가 .env 파일에 설정되어 있지 않습니다.');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';
    final url = Uri.parse(endpoint);
    final String contextText = textSegments.join("\n");

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
            'content': 'You are a Korean dictionary assistant. For the given word, provide a JSON object with exactly the following keys: "dictionaryMeaning", "contextualMeaning", "synonyms", and "antonyms". "dictionaryMeaning" should be a brief definition of the word in Korean. "contextualMeaning" should explain how the word is used in context based on the following text segments: "$contextText". "synonyms" should be an array of similar words in Korean, and "antonyms" should be an array of opposite words in Korean. If any information is not available, set its value to "정보 없음". 모든 결과는 한국어로 제공하세요. Return only the JSON object with no additional text.'
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
        final Map<String, dynamic> data = jsonDecode(message);
        return data;
      } catch (e) {
        throw Exception("ChatGPT 응답 파싱 실패: $e");
      }
    } else {
      throw Exception("ChatGPT API 호출 실패: ${response.statusCode} ${response.body}");
    }
  }

  void _showWordOrSentencePopup(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (_isWordSelected(selectedText)) {
      _showWordPopup(context, selectedText);
    } else {
      _showSentencePopup(context, selectedText);
    }
  }

  /// _showWordPopup: FutureBuilder를 사용하여 API로부터 단어 정보를 받아와 표시
  void _showWordPopup(BuildContext context, String selectedText) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchWordDetails(selectedText, widget.readingData.textSegments),
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
                final List<dynamic> synonyms = data['synonyms'] is List ? data['synonyms'] : [];
                final List<dynamic> antonyms = data['antonyms'] is List ? data['antonyms'] : [];
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
                      // 선택된 단어 표시
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedText,
                          style: body_small_semi(context)
                              .copyWith(color: customColors.primary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // API에서 받아온 결과 표시
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
                              '사전적 의미',
                              style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
                            ),
                            Text(
                              data['dictionaryMeaning'] ?? '정보 없음',
                              style: body_small(context),
                            ),
                            const SizedBox(height: 16),
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
                              '유사어',
                              style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
                            ),
                            Text(
                              synonyms.isNotEmpty ? synonyms.join(', ') : '정보 없음',
                              style: body_small(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '반의어',
                              style: heading_xxsmall(context).copyWith(color: customColors.neutral30),
                            ),
                            Text(
                              antonyms.isNotEmpty ? antonyms.join(', ') : '정보 없음',
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
  /// ChatGPT API를 호출하여 문장 정보를 받아오는 함수
  Future<Map<String, dynamic>> _fetchSentenceDetails(String sentence, List<String> textSegments) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API Key가 .env 파일에 설정되어 있지 않습니다.');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';
    final url = Uri.parse(endpoint);
    final String contextText = textSegments.join("\n");

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
            'content': 'You are a Korean text analysis assistant. For the given sentence, provide a JSON object with exactly the following keys: "contextualMeaning" and "summary". "contextualMeaning" should explain how the sentence is used in context based on the following text segments: "$contextText". "summary" should provide a concise summary of the sentence in Korean. If any information is not available, set its value to "정보 없음". 모든 결과는 한국어로 제공하세요. Return only the JSON object with no additional text.'
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
        throw Exception("ChatGPT 응답 파싱 실패: $e");
      }
    } else {
      throw Exception("ChatGPT API 호출 실패: ${response.statusCode} ${response.body}");
    }
  }

  /// _showSentencePopup: 선택한 문장에 대해 ChatGPT API를 호출하여 문맥상 의미와 요약을 표시
  void _showSentencePopup(BuildContext context, String selectedText) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchSentenceDetails(selectedText, widget.readingData.textSegments),
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

  bool _isWordSelected(String selectedText) {
    return selectedText.split(' ').length == 1;
  }

  void _navigateToChatbot(BuildContext context, TextSelectionDelegate delegate) {
    final String selectedText =
    delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    if (selectedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBot(selectedText: selectedText),
        ),
      );
    }
  }
}

class _NoteDialog extends StatefulWidget {
  final String selectedText;
  final TextEditingController noteController;
  final customColors;

  const _NoteDialog({
    Key? key,
    required this.selectedText,
    required this.noteController,
    required this.customColors,
  }) : super(key: key);

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late Color saveButtonColor;
  bool isQuestionIncluded = false; // 질문 포함 여부 상태

  @override
  void initState() {
    super.initState();
    saveButtonColor = widget.customColors.primary20;

    // TextField 변경에 따라 버튼 색상 업데이트
    widget.noteController.addListener(() {
      setState(() {
        saveButtonColor = widget.noteController.text.isNotEmpty
            ? widget.customColors.primary
            : widget.customColors.primary20;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: widget.customColors.neutral100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '메모',
                textAlign: TextAlign.center,
                style: body_small_semi(context).copyWith(
                  color: widget.customColors.neutral30,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '선택된 문장',
                  style: body_xsmall_semi(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: widget.customColors.neutral90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectedText,
                    style: body_xsmall(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Answer_Section_No_Title(
                controller: widget.noteController,
                customColors: widget.customColors,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isQuestionIncluded = !isQuestionIncluded;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isQuestionIncluded
                          ? widget.customColors.primary
                          : widget.customColors.neutral80,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '질문 포함',
                      style: body_xsmall(context).copyWith(
                        color: isQuestionIncluded
                            ? widget.customColors.primary
                            : widget.customColors.neutral30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: widget.customColors.neutral90,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: saveButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: saveButtonColor == widget.customColors.primary20
                            ? null
                            : () {
                          final note = widget.noteController.text.trim();
                          if (note.isNotEmpty) {
                            debugPrint('메모 저장: $note');
                            debugPrint('질문 포함 상태: $isQuestionIncluded');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.all(16),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: widget.customColors.neutral60.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '메모가 저장되었어요.',
                                      style: body_small_semi(context)
                                          .copyWith(color: widget.customColors.neutral100),
                                    ),
                                  ],
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onVisible: () {
                                Future.delayed(const Duration(seconds: 1), () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                });
                              },
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          '저장',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
