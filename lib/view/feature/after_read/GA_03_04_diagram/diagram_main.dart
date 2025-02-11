import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/start_page/description_section_main.dart';
import '../widget/start_page/icon_section_main.dart';
import '../widget/start_page/title_section_main.dart';
import 'diagram_learning.dart';

class DiagramMainDialog extends StatelessWidget {
  const DiagramMainDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Adjust height to fit the content
                children: [
                  Column(
                    children: [
                      TitleSectionMain(
                        title: "다이어그램 미션",
                        subtitle: "",
                        subtitle2: "",
                        customColors: customColors,
                      ),
                      SVGSection(
                        customColors: customColors,
                        assetPath: "assets/icons/diagram_cover.svg",
                        size: 120,
                      )
                    ],
                  ),

                  Column(
                    children: [
                      DescriptionSection(
                        customColors: customColors,
                        items: [
                          {
                            "icon": Icons.comment_outlined,
                            "text": "단어를 드래그해 트리에 추가해주세요",
                          },
                          {
                            "icon": Icons.access_time_filled,
                            "text": "미션을 시작하면 타이머가 작동해요!",
                          },
                        ],
                      ),
                      ButtonPrimary(
                        function: () {
                          Navigator.pop(context); // To close the current screen (Dialog)
                        },
                        title: '시작하기',
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
