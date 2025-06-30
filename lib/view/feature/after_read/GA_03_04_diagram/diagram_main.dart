import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

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
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      TitleSectionMain(
                        title: "diagram_mission_title".tr(),
                        subtitle: "",
                        subtitle2: "",
                        customColors: customColors,
                      ),
                      SVGSection(
                        customColors: customColors,
                        assetPath: "assets/icons/diagram_cover.svg",
                        size: 120,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      DescriptionSection(
                        customColors: customColors,
                        items: [
                          {
                            "icon": Icons.comment_outlined,
                            "text": "diagram_instruction_drag".tr(),
                          },
                          {
                            "icon": Icons.access_time_filled,
                            "text": "diagram_instruction_timer".tr(),
                          },
                        ],
                      ),
                      ButtonPrimary(
                        function: () {
                          Navigator.pop(context);
                        },
                        title: 'start_button'.tr(),
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
