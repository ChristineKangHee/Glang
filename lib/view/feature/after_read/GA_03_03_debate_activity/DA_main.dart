import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/start_page/description_section_main.dart';
import '../widget/start_page/icon_section_main.dart';
import '../widget/start_page/title_section_main.dart';
import 'DA_learning.dart';
import 'package:easy_localization/easy_localization.dart';

class DebateActivityMain extends StatelessWidget {
  const DebateActivityMain({super.key});

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
                        title: 'debate_mission_title'.tr(), // ***
                        subtitle: "",
                        subtitle2: "",
                        customColors: customColors,
                      ),
                      SizedBox(height: 20,),
                      SVGSection(customColors: customColors),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Column(
                    children: [
                      DescriptionSection(
                        customColors: customColors,
                        items: [
                          {
                            "icon": Icons.comment_outlined,
                            "text": 'debate_instruction_rounds'.tr(), // ***
                          },
                          {
                            "icon": Icons.access_time_filled,
                            "text": 'mission_instruction_timer'.tr(), // ***
                          },
                        ],
                      ),
                      ButtonPrimary(
                        function: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DebatePage(),
                            ),
                          );
                        },
                        title: 'start_button'.tr(), // ***
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
