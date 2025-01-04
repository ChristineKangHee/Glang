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
  final List<String> buttonPopupContents;

  const SectionData({
    required this.color,
    required this.colorOscuro,
    required this.etapa,
    required this.section,
    required this.title,
    required this.sectionDetail,
    required this.buttonPopupContents,
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
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Transform.translate(
          offset: const Offset(0, -70),
          child: Container(
            decoration: BoxDecoration(
              color: customColors.primary,
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
                            '초급 코스 3',
                            style: body_xsmall_semi(context).copyWith(color: customColors.neutral100),
                          ),
                          Text(
                            '주제가 들어감',
                            style: body_large_semi(context).copyWith(color: customColors.neutral100),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(
                                title: data.buttonPopupContents[index],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customColors.neutral100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          '학습하기',
                          style: body_xsmall_semi(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildIconWithText(context, Icons.check_circle, '25%', customColors),
                      const SizedBox(width: 8), // Spacing between items
                      _buildIconWithText(context, Icons.timer, '25분', customColors),
                      const SizedBox(width: 8), // Spacing between items
                      _buildIconWithText(context, Icons.bookmark, '300단어', customColors),
                      const SizedBox(width: 8), // Spacing between items
                      _buildIconWithText(context, Icons.star, '쉬움', customColors),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithText(BuildContext context, IconData icon, String text, CustomColors customColors) {
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

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
          data.buttonPopupContents.length,
              (i) => Container(
            margin: EdgeInsets.only(
              bottom: i != data.buttonPopupContents.length - 1 ? 24.0 : 0,
              left: _getMargin(i),
              right: _getMargin(i, isLeft: false),
            ),
            child: ElevatedButton(
              onPressed: () => _showPopup(context, i, customColors),
              style: ElevatedButton.styleFrom(
                backgroundColor: customColors.primary40,
                fixedSize: const Size(80, 80),
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: Icon(
                Icons.check_rounded,
                color: customColors.neutral100,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
