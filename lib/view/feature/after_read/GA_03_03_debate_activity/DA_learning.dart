import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/feature/after_read/GA_03_03_debate_activity/widgets/debate_notifier.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/message_bubble.dart';
import 'package:readventure/theme/theme.dart';
import '../../../../api/debate_chatgpt_service.dart';
import 'widgets/alert_dialog.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/debate_provider.dart';
import 'widgets/debate_state.dart';

class DebatePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기
    final debateState = ref.watch(debateProvider);
    final debateNotifier = ref.read(debateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("토론", style: heading_xsmall(context).copyWith(color: customColors.neutral30,)),
        centerTitle: true,
        leadingWidth: 90,
        leading: CountdownTimer(
          key: ValueKey(debateState.timerKey), // 타이머 재설정
          initialSeconds: 180, //타이머 초
          onTimerComplete: () {
            debateNotifier.nextRound(); // 라운드 전환
            if (!debateNotifier.state.isFinished) {
              showStartDialog(
                context,
                debateState.currentRound + 1, // 다음 라운드 번호
                "인공지능이 인간의 일자리를 대체하는 것에 대해 어떻게 생각하십니까?",
                !debateState.isUserPro ? "찬성" : "반대",
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // 닫기 버튼
            },
          ),
        ],
      ),
      body: DebateContent(customColors: customColors),
    );
  }
}

class DebateContent extends ConsumerWidget {
  final CustomColors customColors;

  const DebateContent({super.key, required this.customColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 구독
    final debateState = ref.watch(debateProvider);
    final debateNotifier = ref.read(debateProvider.notifier);

    // 라운드 종료 시 결과 다이얼로그 표시
    if (debateState.isFinished) {
      Future.microtask(() {
        _showResultDialog(context, debateNotifier);
      });
    }

    return Container(
      color: customColors.neutral90,
      child: Column(
        children: [
          // 질문 영역
          const QuestionSection(
            data: "맞춤형 읽기 도구와 실시간 피드백 시스템이 전통적인 교육 방식을 대체할 수 있는가?",
          ),
          // 라운드 정보 및 타이머
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "ROUND ${debateState.currentRound} | ${debateState.isUserPro ? '찬성' : '반대'}",
                  style: body_small_semi(context).copyWith(
                    color: customColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: AIDiscussionSection(
              customColors: customColors,
              topic:
              "맞춤형 읽기 도구와 실시간 피드백 시스템이 전통적인 교육 방식을 대체할 수 있는가?",
            ),
          ),
        ],
      ),
    );
  }
  /// 결과 다이얼로그 표시
  void _showResultDialog(BuildContext context, DebateNotifier debateNotifier) {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 클릭 방지
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "학습 결과",
                style: body_small_semi(context)
              ),
              const SizedBox(height: 16),
              // ROUND 1
              _buildRoundResult(
                context: context,
                round: 1,
                stance: "찬성",
                userPercentage: 55,
                aiPercentage: 45,
                customColors: customColors,
              ),
              const SizedBox(height: 16),
              // ROUND 2
              _buildRoundResult(
                context: context,
                round: 2,
                stance: "반대",
                userPercentage: 80,
                aiPercentage: 20,
                customColors: customColors,
              ),
              const SizedBox(height: 16),
              // 종합 평가
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: customColors.neutral90,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "종합 평가",
                      style: body_xsmall_semi(context)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "찬성 측과 반대 측의 주장에서 제시한 경제적 효과에 대한 구체적 수치와 사례 분석이 설득력이 높았습니다.",
                      style: body_small(context)
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      debateNotifier.reset(); // 상태 초기화
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 32.0,
                      ),
                      backgroundColor: customColors.neutral90,
                      foregroundColor: customColors.neutral60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text("다시 쓰기", style: body_small_semi(context).copyWith(color: customColors.neutral60),),
                  ),
                ),
                SizedBox(width: 16,),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                            (route) => route.settings.name == 'LearningActivitiesPage',
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 32.0,
                      ),
                      backgroundColor: customColors.primary,
                      foregroundColor: customColors.neutral100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text("완료", style: body_small_semi(context).copyWith(color: customColors.neutral100),),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 라운드 결과 구성 위젯
  Widget _buildRoundResult({
    required BuildContext context,
    required int round,
    required String stance,
    required int userPercentage,
    required int aiPercentage,
    required CustomColors customColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: customColors.neutral90,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ROUND $round | $stance",
            style: body_small(context).copyWith(color: customColors.neutral30)
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 사용자 퍼센트 및 바
              Expanded(
                flex: userPercentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: customColors.primary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                  ),
                ),
              ),
              // AI 퍼센트 및 바
              Expanded(
                flex: aiPercentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: customColors.neutral60,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "사용자 $userPercentage%",
                style: body_small_semi(context).copyWith(color: customColors.primary)
              ),
              Text(
                "AI $aiPercentage%",
                style: body_small_semi(context).copyWith(color: customColors.neutral60)
              ),
            ],
          ),
        ],
      ),
    );
  }


}

class AIDiscussionSection extends ConsumerStatefulWidget {
  final CustomColors customColors;
  final String topic;

  const AIDiscussionSection({
    super.key,
    required this.customColors,
    required this.topic,
  });

  @override
  _AIDiscussionSectionState createState() => _AIDiscussionSectionState();
}

class _AIDiscussionSectionState extends ConsumerState<AIDiscussionSection> {
  final DebateGPTService _debateService = DebateGPTService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = []; // 채팅 내역

  Future<void> _sendMessage() async {
    final debateState = ref.read(debateProvider);
    final isUserPro = debateState.isUserPro;
    final userMessage = _controller.text.trim();

    if (userMessage.isEmpty) return;

    // 사용자 메시지 추가
    setState(() {
      _messages.add({
        'role': 'user',
        'content': "[${isUserPro ? '찬성' : '반대'}] $userMessage",
      });
    });

    _controller.clear();

    try {
      // AI 응답 요청
      final aiRole = isUserPro ? '반대' : '찬성'; // AI는 반대 역할
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

  @override
  Widget build(BuildContext context) {
    // debateProvider 상태 변화 감지 및 메시지 초기화
    ref.listen<DebateState>(debateProvider, (previous, next) {
      if (previous != null && previous.currentRound != next.currentRound) {
        setState(() {
          _messages = []; // 메시지 초기화
        });
      }
    });

    final debateState = ref.watch(debateProvider);
    final isUserPro = debateState.isUserPro;

    return Column(
      children: [
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
        // 답변 채팅 섹션
        ConstrainedBox(
          constraints: const BoxConstraints(
              maxHeight: 300
          ),
          child: Padding(
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
                      maxLines: 4,
                      minLines: 1,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "시간 내에 의견을 입력해주세요",
                        hintStyle: body_small(context).copyWith(
                          color: widget.customColors.neutral60,
                        ),
                        border: const OutlineInputBorder(
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
        ),
      ],
    );
  }
}

class QuestionSection extends StatelessWidget {
  const QuestionSection({
    super.key,
    required this.data,
  });
  final String data;

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
              data,
              style: body_small_semi(context),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final int initialSeconds; // 초기 타이머 시간 (초 단위)
  final VoidCallback onTimerComplete; // 타이머 완료 시 호출할 콜백

  const CountdownTimer({
    Key? key,
    required this.initialSeconds,
    required this.onTimerComplete,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds; // 남은 시간
  Timer? _timer; // 타이머 객체
  bool _isPaused = false; // 타이머 일시정지 상태

  @override
  void initState() {
    super.initState();
    _startNewTimer(widget.initialSeconds); // 타이머 시작
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      // 새로운 라운드가 시작될 때 타이머 재설정
      _startNewTimer(widget.initialSeconds);
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제
    super.dispose();
  }

  void _startNewTimer(int seconds) {
    _timer?.cancel(); // 기존 타이머 정지
    setState(() {
      _remainingSeconds = seconds; // 남은 시간을 새로 설정
      _isPaused = false; // 타이머 시작 시 일시정지 해제
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--; // 남은 시간 감소
        });
      } else {
        _timer?.cancel(); // 타이머 정지
        widget.onTimerComplete(); // 타이머 완료 콜백 실행
      }
    });
  }

  void _pauseTimer(BuildContext context) {
    _timer?.cancel(); // 타이머 정지
    setState(() {
      _isPaused = true; // 일시정지 상태로 변경
    });

    // 일시정지 다이얼로그 표시
    showPauseDialog(context);
  }

  void _resumeTimer() {
    _startNewTimer(_remainingSeconds); // 남은 시간으로 타이머 재시작
  }

  void showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("일시 정지"),
        content: const Text("타이머가 일시 정지되었습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              _resumeTimer(); // 타이머 재개
            },
            child: const Text("재개"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0'); // 분 계산
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0'); // 초 계산
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: customColors.neutral90,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _isPaused
                ? null // 이미 일시정지 상태면 버튼 비활성화
                : () => _pauseTimer(context),
            child: SvgPicture.asset('assets/icons/pause.svg'),
          ),
          SizedBox(width: 8,),
          Text(
            "$minutes:$seconds", // "분:초" 형식으로 표시
            style: body_small(context).copyWith(color: customColors.neutral30)
          ),
        ],
      ),
    );
  }
}