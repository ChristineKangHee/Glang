/// File: lib/view/feature/reading/GA_02/reading_chatbot.dart
/// Purpose: 읽기중 챗봇 화면을 나타내는 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희, 챗봇 구현 by 박민준

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../api/reading_chatbot_service.dart';
import '../../../../model/reading_data.dart';
import '../../../../theme/font.dart';
import '../../../../util/box_shadow_styles.dart';
import '../../../../util/locale_text.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';

// 챗봇 화면을 나타내는 위젯
class ChatBot extends ConsumerStatefulWidget {
  final String selectedText;
  final ReadingData readingData; // 전체 글 데이터 추가

  ChatBot({required this.selectedText, required this.readingData});

  @override
  _ChatBotState createState() => _ChatBotState();
}


class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'chatbot_greeting'.tr()}
  ];

  final ChatBotService _chatBotService = ChatBotService();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();  // 스크롤 컨트롤러 추가

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'content': message});
        _isLoading = true;
      });

      _controller.clear();

      try {
        // final response = await _chatBotService.getChatResponse(
        //     widget.selectedText,
        //     widget.readingData.textSegments as List<String>,
        //     _messages
        // );
        final segs = llx(context, widget.readingData.textSegments);
        final response = await _chatBotService.getChatResponse(
           widget.selectedText,
            segs,
            _messages,
        );

        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
        });

        // 메시지 추가 후 스크롤을 아래로 내리기
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': '오류가 발생했습니다: $e'});
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 자동으로 스크롤을 아래로 내리는 함수
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,  // 스크롤의 최대 범위로 이동
        duration: Duration(milliseconds: 300),  // 300ms 동안 애니메이션
        curve: Curves.easeInOut,  // 부드러운 애니메이션
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final options = [
      'chatbot_option_explain'.tr(),
      'chatbot_option_background'.tr(),
      'chatbot_option_deep'.tr()
    ];

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: 'chatbot_title'.tr()),
      backgroundColor: customColors.neutral90,
      body: Column(
        children: [
          // 선택된 문장 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(color: customColors.neutral100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('chatbot_selected_sentence'.tr(), style: body_small_semi(context)),
                SizedBox(height: 4),
                ExpandableText(
                  text: widget.selectedText,
                  style: body_small(context),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // 챗봇 대화 영역
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,  // 스크롤 컨트롤러 추가
              child: Column(
                children: [
                  ..._messages.map((msg) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: msg['role'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _buildMessageContainer(msg, customColors),
                    ),
                  )),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),

          _buildOptionsRow(options, customColors),
          _buildMessageInputField(customColors),
        ],
      ),
    );
  }

  // 메시지 컨테이너 생성
  Widget _buildMessageContainer(Map<String, String> msg, customColors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: msg['role'] == 'user' ? customColors.primary : customColors.neutral100,  // 역할에 따른 배경색
        borderRadius: BorderRadius.circular(8),  // 둥근 모서리
      ),
      child: Text(
        msg['content']!,
        style: body_small(context).copyWith(  // 텍스트 스타일 설정
          color: msg['role'] == 'user' ? customColors.neutral100 : customColors.neutral0,
        ),
      ),
    );
  }

  // 사용자 선택 옵션 버튼들
  Widget _buildOptionsRow(List<String> options, customColors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,  // 가로로 스크롤
        itemCount: options.length,  // 항목 수
        separatorBuilder: (_, __) => SizedBox(width: 8),  // 항목 간 구분
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(options[index]),  // 선택 시 메시지 보내기
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: customColors.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: customColors.neutral90 ?? Colors.grey,
                ),
              ),
              child: Center(
                child: Text(
                  options[index],  // 옵션 텍스트 표시
                  style: body_xsmall(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 메시지 입력창
  Widget _buildMessageInputField(customColors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.neutral100,
          borderRadius: BorderRadius.circular(14),  // 둥근 모서리
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                maxLines: 4,  // 최대 4줄
                minLines: 1,  // 최소 1줄
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'chatbot_input_hint'.tr(),
                  hintStyle: body_small(context).copyWith(
                    color: customColors.neutral60,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,  // 테두리 없애기
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: customColors.primary),  // 전송 아이콘
              onPressed: () => _sendMessage(_controller.text),  // 메시지 보내기
            ),
          ],
        ),
      ),
    );
  }
}

// 텍스트가 길면 펼쳐서 보여주는 위젯
class ExpandableText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  ExpandableText({required this.text, required this.style, this.maxLines = 2});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends ConsumerState<ExpandableText> {
  bool _isExpanded = false;  // 텍스트 펼치기 여부

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);  // 커스텀 색상 가져오기
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);  // 텍스트 크기 측정

    final isOverflowing = textPainter.didExceedMaxLines;  // 텍스트 오버플로우 여부 확인

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExpanded)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150),  // 최대 높이 설정
            child: SingleChildScrollView(
              child: Text(widget.text, style: widget.style),
            ),
          )
        else
          Text(
            widget.text,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,  // 텍스트가 길면 생략 표시
          ),
        if (isOverflowing)
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;  // 펼침 상태 변경
              });
            },
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: customColors.neutral30,
            ),
          ),
      ],
    );
  }
}
