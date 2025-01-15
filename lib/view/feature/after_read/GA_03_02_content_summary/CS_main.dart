import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'CS_learning.dart';

class ContentSummaryMain extends StatelessWidget {
  const ContentSummaryMain({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "결말 바꾸기"),
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
                          Title_Section(customColors: customColors),
                          SizedBox(height: 51.h),
                          Icon_Section(customColors: customColors),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 30.h),
                          Description_Section(customColors: customColors),
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
              builder: (context) => CSLearning(),
            ),
          );
        },
        title: '시작하기',
      ),
    );
  }
}

class Description_Section extends StatelessWidget {
  const Description_Section({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(48.w,0,0,0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.import_contacts,
                  color: customColors.primary40, size: 28),
              SizedBox(width: 12.w),
              Text("원문을 보려면 책 아이콘을 클릭하세요!",
                  style: body_small(context)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.access_time_filled,
                  color: customColors.primary40, size: 28),
              SizedBox(width: 12.w),
              Text("학습을 시작하면 타이머가 작동해요!",
                  style: body_small(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class Icon_Section extends StatelessWidget {
  const Icon_Section({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: const ShapeDecoration(
        color: Color(0xFF514FFF),
        shape: OvalBorder(),
      ),
      child: Icon(
        Icons.edit,
        color: customColors.neutral100,
        size: 80,
      ),
    );
  }
}

class Title_Section extends StatelessWidget {
  const Title_Section({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("글의 결말을 읽고", style: body_medium_semi(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "나만의 결말",
              style: body_medium_semi(context)
                  .copyWith(color: customColors.primary),
            ),
            Text("을 만들어볼까요?", style: body_medium_semi(context)),
          ],
        ),
      ],
    );
  }
}
