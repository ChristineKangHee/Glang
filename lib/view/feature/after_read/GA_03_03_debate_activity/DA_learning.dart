import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/message_bubble.dart';
import 'package:readventure/theme/theme.dart';
import '../../../../api/debate_chatgpt_service.dart';

class DebatePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기

    return Scaffold(
      appBar: AppBar(
        title: Text("토론"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // 닫기 버튼
            },
          ),
        ],
      ),
      body: Container(
        color: customColors.neutral90,
        child: Column(
          children: [
            // 질문 영역
            QuestionSection(),
            // 라운드 정보 영역
            RoundSection(customColors: customColors),
            // AI와 대화 섹션
            Expanded(
              child: AIDiscussionSection(
                customColors: customColors, topic: '인공 지능이 인간의 일자리를 대체하는 것에 대해 어떻게 생각하십니까?',
              ),
            ),
            // 의견 입력 필
            // InputSection(customColors: customColors),
          ],
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("일시 정지"),
        content: Text("타이머가 일시 정지되었습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("재개"),
          ),
        ],
      ),
    );
  }
}

class AIDiscussionSection extends StatefulWidget {
  final CustomColors customColors;
  final String topic;

  const AIDiscussionSection({
    super.key,
    required this.customColors,
    required this.topic,
  });

  @override
  State<AIDiscussionSection> createState() => _AIDiscussionSectionState();
}

class _AIDiscussionSectionState extends State<AIDiscussionSection> {
  final DebateGPTService _debateService = DebateGPTService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  int _currentRound = 1; // 현재 라운드
  bool _isUserPro = true; // 사용자가 찬성인지 여부

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    // 사용자 메시지 추가
    setState(() {
      _messages.add({
        'role': 'user',
        'content': "[${_isUserPro ? '찬성' : '반대'}] $userMessage",
      });
    });

    _controller.clear();

    try {
      // AI 응답 요청
      final aiRole = _isUserPro ? '반대' : '찬성'; // AI는 반대 역할
      final response = await _debateService.getDebateResponse(
        widget.topic,
        "$aiRole 관점에서 대답해주세요: $userMessage",
      );

      // AI 메시지 추가
      setState(() {
        _messages.add({'role': 'assistant', 'content': "[${aiRole}] $response"});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'error', 'content': '응답을 가져오지 못했습니다.'});
      });
    }
  }

  void _nextRound() {
    setState(() {
      _currentRound++;
      _isUserPro = !_isUserPro; // 찬반 역할 전환
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 현재 라운드 및 찬반 표시
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ROUND $_currentRound | ${_isUserPro ? '찬성' : '반대'}",
                style: body_small_semi(context).copyWith(
                  color: widget.customColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: _nextRound, // 버튼 클릭 시 라운드 전환
                child: Text("다음 라운드"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message['role'] == 'user';
              final isError = message['role'] == 'error';

              return MessageBubble(
                content: message['content'] ?? '',
                isUser: isUser,
                isError: isError,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.customColors.neutral100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "시간 내에 의견을 입력해주세요",
                      hintStyle: body_small(context).copyWith(
                        color: widget.customColors.neutral60,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: widget.customColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


/*
** _AIDiscussionSectionState 에서 대체 **
class InputSection extends StatelessWidget {
  const InputSection({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                decoration: InputDecoration(
                  hintStyle: body_small(context).copyWith(color: customColors.neutral60),
                  hintText: "시간 내에 의견을 입력해주세요",
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: customColors.primary),
              onPressed: () {
                // 의견 전송 처리
              },
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
*/

class RoundSection extends StatelessWidget {
  const RoundSection({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customColors.neutral90,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Divider(color: customColors.primary, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "ROUND 1 | 찬성",
                style: body_xsmall(context).copyWith(color: customColors.primary)
              ),
            ),
            Expanded(
              child: Divider(color: customColors.primary, thickness: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionSection extends StatelessWidget {
  const QuestionSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.message_rounded, size: 32),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "인공 지능이 인간의 일자리를 대체하는 것에 대해 어떻게 생각하십니까?",
              style: body_small_semi(context),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
