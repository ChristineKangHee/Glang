import 'package:flutter/material.dart';
import '../../util/box_shadow_styles.dart';
import 'course_subdetail.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class SectionData {
  final Color color;
  final Color colorOscuro;
  final int etapa;
  final int section;
  final String title;
  final String sectionDetail;
  final List<String> subdetailTitle;
  final List<String> totalTime;
  final List<String> achievement;
  final List<String> difficultyLevel;
  final List<String> textContents;
  final List<String> imageUrls;
  final List<List<String>> missions;
  final List<List<String>> effects;
  final List<String> status; // New status list to track button state

  SectionData({
    required this.color,
    required this.colorOscuro,
    required this.etapa,
    required this.section,
    required this.title,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.sectionDetail,
    required this.subdetailTitle,
    required this.textContents,
    required this.imageUrls,
    required this.missions,
    required this.effects,
    required this.status, // Initialize status
  });
}

class Section extends StatelessWidget {
  final SectionData data;

  const Section({super.key, required this.data});

  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    } else {
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    }
  }

  void _showPopup(BuildContext context, int index, CustomColors customColors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
            child: Container(
              decoration: BoxDecoration(
                color: customColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: BoxShadowStyles.shadow1(context),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20),
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
                              data.title,
                              style: body_xsmall_semi(context).copyWith(
                                  color: customColors.neutral100),
                            ),
                            Text(
                              data.subdetailTitle[index],
                              style: body_large_semi(context).copyWith(
                                  color: customColors.neutral100),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailPage(
                                      title: data.subdetailTitle[index],
                                      time: data.totalTime[index].toString(),
                                      level: data.difficultyLevel[index],
                                      description: data.textContents[index],
                                      imageUrl: data.imageUrls[index],
                                      mission: data.missions[index],
                                      effect: data.effects[index],
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
                            '시작하기',
                            style: body_xsmall_semi(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildIconWithText(context, Icons.check_circle,
                            data.achievement[index] + '%', customColors),
                        const SizedBox(width: 8), // Spacing between items
                        _buildIconWithText(
                            context, Icons.timer, data.totalTime[index] + '분',
                            customColors),
                        const SizedBox(width: 8), // Spacing between items
                        _buildIconWithText(
                            context, Icons.star, data.difficultyLevel[index],
                            customColors),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildIconWithText(BuildContext context, IconData icon, String text,
      CustomColors customColors) {
    return Row(
      children: [
        Icon(icon, color: customColors.neutral90, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: body_xsmall_semi(context).copyWith(
              color: customColors.neutral90),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: data.color),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.title, style: body_large_semi(context)),
                Text(data.sectionDetail, style: body_small(context)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        ...List.generate(
          data.subdetailTitle.length,
              (i) =>
              Container(
                margin: EdgeInsets.only(
                  bottom: i != data.subdetailTitle.length - 1 ? 24.0 : 0,
                  left: _getMargin(i),
                  right: _getMargin(i, isLeft: false),
                ),
                child: ElevatedButton(
                  onPressed: () => _showPopup(context, i, customColors),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonState(i, customColors).backgroundColor,
                    fixedSize: const Size(80, 80), // Keep size fixed
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: _getButtonState(i, customColors).icon,
                ),
              ),
        ),
      ],
    );
  }

  // Combined function that returns both icon and background color
  _ButtonState _getButtonState(int index, CustomColors customColors) {
    String status = data.status[index];
    IconData icon;
    Color? backgroundColor;

    switch (status) {
      case 'completed':
        icon = Icons.check;
        backgroundColor = customColors.primary40;
        break;
      case 'before_completion':
        icon = Icons.lock;
        backgroundColor = customColors.neutral80;
        break;
      default:
        icon = Icons.play_arrow_rounded;
        backgroundColor = customColors.primary;
    }

    // Check if the icon is play_arrow_rounded and set its size to 50
    double iconSize = (icon == Icons.play_arrow_rounded) ? 50.0 : 30.0;

    return _ButtonState(
      icon: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: (status == 'before_completion')
              ? customColors.neutral30
              : customColors.neutral100,
          size: iconSize,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class _ButtonState {
  final Widget icon;
  final Color? backgroundColor;

  _ButtonState({required this.icon, required this.backgroundColor});
}
