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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 95.0),
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
            child: StatusButton(status: data.status[i], onPressed: () => _showPopup(context, i),),
          ),
        ),
      ],
    );
  }
}
