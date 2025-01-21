import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../after_read/widget/start_page/description_section_main.dart';
import '../../after_read/widget/start_page/icon_section_main.dart';
import '../../after_read/widget/start_page/title_section_main.dart';
import 'CR_learning.dart';

class CoverResearchMain extends StatelessWidget {
  const CoverResearchMain({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "표지 탐구하기"),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // 화면의 전체 높이에 맞추기
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  color: customColors.neutral90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 117.h),
                          TitleSectionMain(
                            title: "표지를 보고",           // 첫번째 줄
                            subtitle: "제목과 내용",                 // 두번째 줄 primary color
                            subtitle2: "을 유추해볼까요?",  // 두번째 줄 black color
                            customColors: customColors,
                          ),
                          SizedBox(height: 51.h),
                          IconSection(customColors: customColors),
                          SizedBox(height: 51.h),
                          Text("하단에 제시된 키워드를\n참고해보세요!", textAlign: TextAlign.center, style: body_small(context),),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 30.h),
                          // DescriptionSection(
                          //   customColors: customColors, // 필수: CustomColors 전달
                          // ),
                          SizedBox(height: 50.h),
                          Button_Section(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Button_Section extends StatelessWidget {
  const Button_Section({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ButtonPrimary(
        function: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CRLearning(),
            ),
          );
        },
        title: '시작하기',
      ),
    );
  }
}