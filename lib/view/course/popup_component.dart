// popup_component.dart
import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../util/box_shadow_styles.dart';
import 'course_subdetail.dart';

class SectionPopup extends StatelessWidget {
  final String title;
  final String subTitle;
  final String time;
  final String level;
  final String description;
  final List<String> missions;
  final List<String> effects;
  final String achievement;
  final String status; // 학습 상태 추가

  const SectionPopup({
    super.key,
    required this.title,
    required this.subTitle,
    required this.time,
    required this.level,
    required this.description,
    required this.missions,
    required this.effects,
    required this.achievement,
    required this.status, // 학습 상태 추가
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    Color? cardColor;

    // 상태에 따른 색상 설정
    switch (status) {
      case 'start':
      case 'in_progress':
        cardColor = customColors.primary;
        break;
      case 'completed':
        cardColor = customColors.primary40;
        break;
      case 'locked':
      default:
        cardColor = customColors.neutral80;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: body_xsmall_semi(context)
                          .copyWith(color: customColors.neutral100),
                    ),
                    Text(
                      subTitle,
                      style: body_large_semi(context)
                          .copyWith(color: customColors.neutral100),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: status == 'locked'
                      ? null
                      : () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailPage(
                          title: subTitle,
                          time: time,
                          level: level,
                          description: description,
                          mission: missions,
                          effect: effects,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    status == 'locked' ? '잠김' : '시작하기',
                    style: body_xsmall_semi(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildIconWithText(context, Icons.check_circle,
                    '$achievement%', customColors),
                const SizedBox(width: 8),
                _buildIconWithText(
                    context, Icons.timer, '$time 분', customColors),
                const SizedBox(width: 8),
                _buildIconWithText(context, Icons.star, level, customColors),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithText(
      BuildContext context, IconData icon, String text, CustomColors customColors) {
    return Row(
      children: [
        Icon(icon, color: customColors.neutral90, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: body_xsmall_semi(context).copyWith(color: customColors.neutral90),
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
      case 'start':
      case 'in_progress':
        buttonColor = customColors.primary;
        buttonIcon = Icons.play_arrow_rounded;
        iconSize = 40.0;
        iconColor = customColors.neutral100;
        break;
      case 'completed':
        buttonColor = customColors.primary40;
        buttonIcon = Icons.check_rounded;
        iconSize = 40.0;
        iconColor = customColors.neutral100;
        break;
      case 'locked':
      default:
        buttonColor = customColors.neutral80;
        buttonIcon = Icons.lock_rounded;
        iconSize = 24.0;
        iconColor = customColors.neutral30;
        break;
    }

    return status == 'start' || status == 'in_progress'
        ? PulsatingPlayButton(
            onPressed: onPressed,
            buttonColor: buttonColor,
            buttonIcon: buttonIcon,
            iconSize: iconSize,
            iconColor: iconColor,
          )
        : ElevatedButton(
      onPressed: status == 'locked' ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        fixedSize: const Size(80, 80),
        elevation: 0,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: Icon(buttonIcon, size: iconSize, color: Colors.white),
    );
  }
}

class PulsatingPlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  final buttonColor;
  final buttonIcon;
  final iconSize;
  final iconColor;

  const PulsatingPlayButton({Key? key, required this.onPressed, required this.buttonColor, this.buttonIcon, this.iconSize, this.iconColor})
      : super(key: key);

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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // AnimatedBuilder(
          //   animation: _controller,
          //   builder: (context, child) {
          //     return Container(
          //       width: 100 * _scaleAnimation.value,
          //       height: 100 * _scaleAnimation.value,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: customColors.accent?.withOpacity(_opacityAnimation.value),
          //       ),
          //     );
          //   },
          // ),
          InkWell(
            onTap: widget.onPressed,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.buttonColor,
              ),
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
