import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/start_page/description_section_main.dart';
import '../widget/start_page/icon_section_main.dart';
import '../widget/start_page/title_section_main.dart';

class DebateActivityMain extends StatelessWidget {
  final VoidCallback onStart;

  const DebateActivityMain({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  TitleSectionMain(
                    title: "토론 미션",
                    subtitle: "",
                    subtitle2: "",
                    customColors: customColors,
                  ),
                  SizedBox(height: 20.h),
                  SVGSection(customColors: customColors),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                children: [
                  DescriptionSection(
                    customColors: customColors,
                    items: const [
                      {
                        "icon": Icons.comment_outlined,
                        "text": "찬성/반대 총 4번을 반복해요!",
                      },
                      {
                        "icon": Icons.access_time_filled,
                        "text": "미션을 시작하면 타이머가 작동해요!",
                      },
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ButtonPrimary(
                    function: () {
                      Navigator.pop(context);
                    },
                    title: '시작하기',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
