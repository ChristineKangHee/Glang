import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RdBefore extends StatelessWidget {
  const RdBefore({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "읽기의 중요성", automaticallyImplyLeading: false,
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
                          Text("오늘도 기대를 갖고 글을 읽어볼까요?", style: body_medium_semi(context),),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              height: 450.h,
                              child: Image.asset("assets/images/cover.png"),
                            ),
                          ),
                          // SizedBox(height: 117.h),
                          // TitleSectionMain(title: "자유롭게", subtitle: "", subtitle2: "느낀점을 작성해주세요", customColors: customColors,),
                          // SizedBox(height: 51.h),
                          // IconSection(customColors: customColors, icon: Icons.edit,),
                          SizedBox(height: 16,),
                          Text("단어나 문장을 선택하면", style: body_small(context),),
                          Text("메모, 밑줄, 해석, 챗봇 기능을 사용할 수 있어요!", style: body_small(context),),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 30.h),
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
          Navigator.pushNamed(context, '/rdmain');
        },
        title: '준비완료',
      ),
    );
  }
}