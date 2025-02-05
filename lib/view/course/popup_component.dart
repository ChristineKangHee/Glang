// popup_component.dart
import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/course/course_subdetail.dart';
import 'package:readventure/model/stage_data.dart';
import '../../model/section_data.dart';
import '../../util/box_shadow_styles.dart';

class SectionPopup extends StatelessWidget {
  final StageData stage; // 🔹 이제 StageData 전체를 받는다.

  const SectionPopup({
    super.key,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // 상태에 따른 색상 설정
    Color? cardColor;
    Color? titleColor;
    Color? subTitleColor;
    final statusStr = _stageStatusToString(stage.status);

    switch (statusStr) {
      case 'inProgress':
        cardColor = customColors.primary;
        titleColor = customColors.neutral100;
        subTitleColor = customColors.neutral100;
        break;
      case 'completed':
        cardColor = customColors.primary40;
        titleColor = customColors.neutral30;
        subTitleColor = customColors.neutral30;
        break;
      case 'locked':
      default:
        cardColor = customColors.neutral80;
        titleColor = customColors.neutral30;
        subTitleColor = customColors.neutral30;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BoxShadowStyles.shadow1(context),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단: 코스 제목 + 스테이지 제목 + 시작하기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 예: "코스 제목" 대신 stageId나 다른 정보를 표시할 수도 있음
                    Text(
                      "스테이지 ID: ${stage.stageId}",
                      style: body_xsmall_semi(context)
                          .copyWith(color: titleColor),
                    ),
                    Text(
                      stage.subdetailTitle,
                      style: body_large_semi(context)
                          .copyWith(color: subTitleColor),
                    ),
                  ],
                ),
                // 시작하기 버튼
                ElevatedButton(
                  onPressed: stage.status == StageStatus.locked
                      ? null
                      : () {
                    // 코스 상세 화면 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailPage(stage: stage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stage.status == StageStatus.locked
                        ? customColors.neutral60
                        : customColors.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    stage.status == StageStatus.locked ? '잠겨있음' : '시작하기',
                    style: body_xsmall_semi(context).copyWith(
                      color: customColors.neutral0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 하단: 진행도%, 시간, 난이도 표시
            Row(
              children: [
                _buildIconWithText(
                  context,
                  Icons.check_circle,
                  '${stage.achievement}%',
                  customColors,
                  (stage.status == StageStatus.completed ||
                      stage.status == StageStatus.locked)
                      ? customColors.neutral30!
                      : customColors.neutral90!,
                ),
                const SizedBox(width: 8),
                _buildIconWithText(
                  context,
                  Icons.timer,
                  '${stage.totalTime}분',
                  customColors,
                  (stage.status == StageStatus.completed ||
                      stage.status == StageStatus.locked)
                      ? customColors.neutral30!
                      : customColors.neutral90!,
                ),
                const SizedBox(width: 8),
                _buildIconWithText(
                  context,
                  Icons.star,
                  stage.difficultyLevel,
                  customColors,
                  (stage.status == StageStatus.completed ||
                      stage.status == StageStatus.locked)
                      ? customColors.neutral30!
                      : customColors.neutral90!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // StageStatus -> String
  String _stageStatusToString(StageStatus status) {
    switch (status) {
      case StageStatus.locked:
        return 'locked';
      case StageStatus.inProgress:
        return 'inProgress';
      case StageStatus.completed:
        return 'completed';
    }
  }

  Widget _buildIconWithText(
      BuildContext context,
      IconData icon,
      String text,
      CustomColors customColors,
      Color iconTextColor,
      ) {
    return Row(
      children: [
        Icon(icon, color: iconTextColor, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: body_xsmall_semi(context).copyWith(color: iconTextColor),
        ),
      ],
    );
  }
}


class StatusButton extends StatelessWidget {
  final String status;
  final VoidCallback onPressed;

  const StatusButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color? buttonColor;
    IconData buttonIcon;
    double iconSize;
    Color? iconColor;
    double iconWeight;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // 상태에 따른 색상, 아이콘 및 아이콘 크기 설정
    switch (status) {
      case 'inProgress':
        buttonColor = customColors.primary;
        buttonIcon = Icons.play_arrow_rounded;
        iconSize = 40.0;
        iconColor = customColors.neutral100!;
        break;

      case 'completed':
        buttonColor = customColors.primary40;
        buttonIcon = Icons.check_rounded;
        iconSize = 40.0;
        iconColor = customColors.neutral100!;
        break;

      case 'locked':
      default:
        buttonColor = customColors.neutral80;
        buttonIcon = Icons.lock_rounded;
        iconSize = 24.0;
        iconColor = customColors.neutral30!;
        break;
    }

    return status == 'start' || status == 'inProgress'
        ? PulsatingPlayButton(
            onPressed: onPressed,
            buttonColor: buttonColor??Colors.purple,
            buttonIcon: buttonIcon,
            iconSize: iconSize,
            iconColor: iconColor??Colors.white,
          )
        : ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        fixedSize: const Size(80, 80),
        elevation: 0,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: Icon(buttonIcon, size: iconSize, color: customColors.neutral30),
    );
  }
}
class PulsatingPlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color buttonColor;
  final IconData buttonIcon;
  final double iconSize;
  final Color iconColor;

  const PulsatingPlayButton({
    Key? key,
    required this.onPressed,
    required this.buttonColor,
    required this.buttonIcon,
    required this.iconSize,
    required this.iconColor,
  }) : super(key: key);

  @override
  _PulsatingPlayButtonState createState() => _PulsatingPlayButtonState();
}

class _PulsatingPlayButtonState extends State<PulsatingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // 고정된 크기 설정
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 100 * _scaleAnimation.value,
                height: 100 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.buttonColor.withOpacity(_opacityAnimation.value),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: widget.buttonColor,
              fixedSize: const Size(80, 80), // 버튼 크기 고정
              elevation: 0,
            ),
            child: Transform.translate(
              offset: const Offset(-4, 0), // 아이콘을 왼쪽으로 4px 이동
              child: Icon(
                widget.buttonIcon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
