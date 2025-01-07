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
  final String imageUrl;
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
    required this.imageUrl,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
      child: Container(
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
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            title: subTitle,
                            time: time,
                            level: level,
                            description: description,
                            imageUrl: imageUrl,
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
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // 상태에 따른 색상, 아이콘 및 아이콘 크기 설정
    switch (status) {
      case 'start':
        buttonColor = customColors.primary;
        buttonIcon = Icons.play_arrow;
        iconSize = 36.0;
        iconColor = customColors.neutral100;
        break;
      case 'in_progress':
        buttonColor = customColors.primary;
        buttonIcon = Icons.pause;
        iconSize = 36.0;
        iconColor = customColors.neutral100;
        break;
      case 'completed':
        buttonColor = customColors.primary40;
        buttonIcon = Icons.check_rounded;
        iconSize = 32.0;
        iconColor = customColors.neutral100;
        break;
      case 'locked':
      default:
        buttonColor = customColors.neutral80;
        buttonIcon = Icons.lock;
        iconSize = 24.0;
        iconColor = customColors.neutral30;
        break;
    }

    return ElevatedButton(
      onPressed: status == 'locked' ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        fixedSize: const Size(80, 80),
        elevation: 0,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: Icon(buttonIcon, size: iconSize, color: Colors.white,),
    );
  }
}
