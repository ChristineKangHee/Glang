import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../api/reading_chatbot_service.dart';
import '../../../theme/font.dart';
import '../../../util/box_shadow_styles.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class ChatBot extends ConsumerStatefulWidget {
  final String selectedText;

  ChatBot({required this.selectedText});

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': '어떤 도움이 필요하신가요?'}
  ];
  final ChatBotService _chatBotService = ChatBotService();
  bool _isLoading = false;

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'content': message});
        _isLoading = true;
      });

      _controller.clear();

      try {
        final response = await _chatBotService.getChatResponse(widget.selectedText, _messages);
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
        });
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

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final options = [
      '문장을 쉽게 풀어줘',
      '필요한 배경지식을 알려줘',
      '더 깊이 탐구해야 할 부분은 뭐야?'
    ];

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '챗봇'),
      backgroundColor: customColors.neutral90,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(color: customColors.neutral100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 문장',
                          style: body_small_semi(context),
                        ),
                        SizedBox(height: 4),
                        ExpandableText(
                          text: widget.selectedText,
                          style: body_small(context),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  ..._messages.map((msg) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: msg['role'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg['role'] == 'user'
                              ? customColors.primary
                              : customColors.neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          msg['content']!,
                          style: body_small(context).copyWith(
                            color: msg['role'] == 'user'
                                ? customColors.neutral100
                                : customColors.neutral0,
                          ),
                        ),
                      ),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendMessage(options[index]),
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
                        options[index],
                        style: body_xsmall(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: customColors.neutral100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 4,
                      minLines: 1,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "메시지 입력",
                        hintStyle: body_small(context).copyWith(
                          color: customColors.neutral60,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: customColors.primary),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  ExpandableText({required this.text, required this.style, this.maxLines = 2});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends ConsumerState<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExpanded)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Text(widget.text, style: widget.style),
            ),
          )
        else
          Text(
            widget.text,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        if (isOverflowing)
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
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