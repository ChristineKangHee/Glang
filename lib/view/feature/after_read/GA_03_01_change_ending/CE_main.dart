import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'CE_learning.dart';

class ChangeEndingMain extends StatelessWidget {
  const ChangeEndingMain({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "결말 바꾸기"),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: 1.sh,
              color: customColors.neutral90,
              // padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 117,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("글의 결말을 읽고", style: body_medium_semi(context),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("나만의 결말", style: body_medium_semi(context).copyWith(color: customColors.primary)),
                            Text("을 만들어볼까요?", style: body_medium_semi(context),),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 51,),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: ShapeDecoration(
                        color: Color(0xFF514FFF),
                        shape: OvalBorder(),
                      ),
                      child: Icon(Icons.import_contacts, color: customColors.neutral100, size: 80,),
                    ),
                    SizedBox(height: 173.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 31,),
                        Icon(Icons.import_contacts, color: customColors.primary40, size: 28,),
                        SizedBox(width: 12,),
                        Text("원문을 보려면 책 아이콘을 클릭하세요!", style: body_small(context),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 31,),
                        Icon(Icons.access_time_filled, color: customColors.primary40, size: 28,),
                        SizedBox(width: 12,),
                        Text("학습을 시작하면 타이머가 작동해요!", style: body_small(context),),
                      ],
                    ),
                    SizedBox(height: 50,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ButtonPrimary(
                        function: () {
                          print("Button pressed");
                          //function 은 상황에 맞게 재 정의 할 것.
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CELearning()));
                        },
                        title: '시작하기',
                        // 버튼 안에 들어갈 텍스트.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      )
    );
  }
}
