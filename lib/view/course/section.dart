import 'package:flutter/material.dart';
import '../../model/section_data.dart';
import '../../util/box_shadow_styles.dart';
import 'course_subdetail.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'popup_component.dart';

class Section extends StatelessWidget {
  final SectionData data; // 섹션 데이터

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

  void _showPopup(BuildContext context, int index) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // 뒤쪽 화면이 클릭 가능하도록 설정
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 60.0),
                padding: const EdgeInsets.all(20.0),
                child: SectionPopup(
                  title: data.title,
                  subTitle: data.subdetailTitle[index],
                  time: data.totalTime[index],
                  level: data.difficultyLevel[index],
                  description: data.textContents[index],
                  missions: data.missions[index],
                  effects: data.effects[index],
                  achievement: data.achievement[index],
                  status: data.status[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    // Check if the status is either 'start' or 'completed'
    Color? containerColor = data.status.contains('start') || data.status.contains('completed')
        ? customColors.primary10
        : customColors.neutral90;

    return Container(
      color: containerColor,  // Apply the dynamically set color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: customColors.neutral100,
            width: double.infinity,
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
                (i) => Container(
              margin: EdgeInsets.only(
                bottom: i != data.subdetailTitle.length - 1 ? 24.0 : 0,
                left: _getMargin(i),
                right: _getMargin(i, isLeft: false),
              ),
              child: StatusButton(
                status: data.status[i],
                onPressed: () => _showPopup(context, i),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
