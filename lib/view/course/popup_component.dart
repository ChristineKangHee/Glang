// File: lib/view/course/popup_component.dart
// Last Modified: 2025-08-13 by ChatGPT (StatusButton 복구, 다국어 유지)

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/course/course_subdetail.dart';
import 'package:readventure/model/stage_data.dart';
import 'package:easy_localization/easy_localization.dart' hide tr;

// CHANGED: tr 유틸
import '../../localization/tr.dart';

class SectionPopup extends StatelessWidget {
  final StageData stage;
  const SectionPopup({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = context.glangLocale;

    // 상태별 색상
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
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단: 스테이지 ID + 타이틀 + 시작 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'stage_id'.tr(args: [stage.stageId]),
                        style: body_xsmall_semi(context).copyWith(color: titleColor),
                      ),
                      Text(
                        tr(stage.subdetailTitle, locale), // CHANGED
                        style: body_large_semi(context).copyWith(color: subTitleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: stage.status == StageStatus.locked
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseDetailPage(stage: stage)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stage.status == StageStatus.locked
                        ? customColors.neutral60
                        : customColors.neutral100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    stage.status == StageStatus.locked ? 'locked'.tr() : 'start_button'.tr(),
                    style: body_xsmall_semi(context).copyWith(color: customColors.neutral0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // 하단: 진행도/시간/난이도
            Row(
              children: [
                _buildIconWithText(
                  context,
                  Icons.check_circle,
                  '${stage.achievement}%',
                  customColors,
                  (stage.status == StageStatus.completed || stage.status == StageStatus.locked)
                      ? customColors.neutral30!
                      : customColors.neutral90!,
                ),
                const SizedBox(width: 8),
                _buildIconWithText(
                  context,
                  Icons.timer,
                  'time_minutes'.tr(args: [stage.totalTime.toString()]),
                  customColors,
                  (stage.status == StageStatus.completed || stage.status == StageStatus.locked)
                      ? customColors.neutral30!
                      : customColors.neutral90!,
                ),
                const SizedBox(width: 8),
                _buildIconWithText(
                  context,
                  Icons.star,
                  tr(stage.difficultyLevel, locale), // CHANGED
                  customColors,
                  (stage.status == StageStatus.completed || stage.status == StageStatus.locked)
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

/// --------------------------
/// RESTORED: StatusButton + PulsatingPlayButton
/// --------------------------

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
    final customColors = Theme.of(context).extension<CustomColors>()!;

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
      buttonColor: buttonColor ?? Colors.purple,
      buttonIcon: buttonIcon,
      iconSize: iconSize,
      iconColor: iconColor ?? Colors.white,
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
        shape: const CircleBorder(),
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
  State<PulsatingPlayButton> createState() => _PulsatingPlayButtonState();
}

class _PulsatingPlayButtonState extends State<PulsatingPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();
  late final Animation<double> _scaleAnimation =
  Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  late final Animation<double> _opacityAnimation =
  Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
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
              fixedSize: const Size(80, 80),
              elevation: 0,
            ),
            child: Transform.translate(
              offset: const Offset(-4, 0),
              child: Icon(widget.buttonIcon, color: widget.iconColor, size: widget.iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
