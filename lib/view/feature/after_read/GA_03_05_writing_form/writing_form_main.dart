import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/view/feature/after_read/GA_03_05_writing_form/writing_form_learning.dart';
import '../widget/start_page/description_section_main.dart';
import '../widget/start_page/icon_section_main.dart';
import '../widget/start_page/title_section_main.dart';

class WritingFormMain extends StatelessWidget {
  const WritingFormMain({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "문장 구조 연습", automaticallyImplyLeading: false,
        onIconPressed: () {
          Navigator.pop(context);
        } ,
      ),
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
                          TitleSectionMain(title: "문장 구조를 따라", subtitle: "", subtitle2: "빈칸에 직접 적용해보세요", customColors: customColors,),
                          SizedBox(height: 51.h),
                          IconSection(customColors: customColors, icon: Icons.edit,),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 30.h),
                          DescriptionSection(
                            customColors: customColors, // 필수: CustomColors 전달
                            items: [
                              {
                                "icon": Icons.comment_outlined, // 사용자 지정 아이콘
                                "text": "빈칸에 알맞는 단어를 작성해주세요!",
                              },
                              {
                                "icon": Icons.access_time_filled, // 사용자 지정 아이콘
                                "text": "학습을 시작하면 타이머가 작동해요!",
                              },
                            ],
                          ),
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
              builder: (context) => SentencePractice(),
            ),
          );
        },
        title: '시작하기',
      ),
    );
  }
}