// alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:readventure/theme/font.dart';

import '../../../../../theme/theme.dart';

void showStartDialog(BuildContext context, int roundNumber, String topic, String stance) {
  showDialog(
    context: context,
    barrierDismissible: false, // 다이얼로그 외부 클릭 비활성화
    builder: (BuildContext context) {
      return _StartDialogContent(
        roundNumber: roundNumber,
        topic: topic,
        stance: stance,
      );
    },
  );
}

class _StartDialogContent extends StatefulWidget {
  final int roundNumber;
  final String topic;
  final String stance;

  const _StartDialogContent({
    Key? key,
    required this.roundNumber,
    required this.topic,
    required this.stance,
  }) : super(key: key);

  @override
  _StartDialogContentState createState() => _StartDialogContentState();
}

class _StartDialogContentState extends State<_StartDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // 애니메이션 컨트롤러
  late Animation<double> _progressAnimation; // 퍼센트 값 애니메이션

  @override
  void initState() {
    super.initState();

    // AnimationController 초기화 (3초 동안 애니메이션 진행)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 애니메이션 길이 3초
    );

    // AnimationController의 진행도를 `Tween`으로 변환 (0.0 ~ 1.0)
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // 애니메이션 값이 업데이트될 때 UI 갱신
      });

    // 애니메이션 시작
    _controller.forward();

    // 3초 후 다이얼로그 자동 종료
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // AnimationController 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final Color stanceColor = widget.stance == "반대" ? customColors.error! : customColors.primary!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 라운드 정보
          Text(
            "ROUND ${widget.roundNumber}",
            style: body_small_semi(context).copyWith(color: customColors.neutral30)
          ),
          const SizedBox(height: 16),
          // 토론 주제
          // Text(
          //   widget.topic,
          //   textAlign: TextAlign.center,
          //   style: body_medium_semi(context).copyWith(color: customColors.neutral30),
          // ),
          // 입장 정보
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                    text: "당신은 ",
                    style: body_medium_semi(context)
                ),
                TextSpan(
                    text: "'${widget.stance}' ",
                    style: body_medium_semi(context).copyWith(color: stanceColor), // 변경된 색상 적용
                ),
                TextSpan(
                    text: "입장입니다",
                    style: body_medium_semi(context)
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 원형 타이머
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 8.0,
            percent: _progressAnimation.value, // 애니메이션 값으로 진행도 설정
            center: Text(
              "${(3 - (3 * _progressAnimation.value)).ceil()}초", // 남은 시간 표시
              style: body_large_semi(context).copyWith(color: customColors.neutral30),
            ),
            progressColor: customColors.primary, // 진행 색상
            backgroundColor: customColors.neutral80!, // 배경 색상
            circularStrokeCap: CircularStrokeCap.round, // 끝을 둥글게 처리
          ),
        ],
      ),
    );
  }
}
