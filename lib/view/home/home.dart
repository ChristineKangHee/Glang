/// File: home.dart
/// Purpose: 메인 화면
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'package:readventure/viewmodel/theme_controller.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';

class MyHomePage extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final name = "제로";

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_Logo(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column( // 나중에 섹션 분리할 것
                  children: [
                    Text("안녕하세요, $name님!", style: heading_medium(context),),
                    Text("오늘의 학습 목표를 달성해 보세요!", style: body_xsmall(context),),
                  ],
                ),
                SizedBox(height: 24,),
                Column(
                  children: [
                    Text("진행 중인 학습", style: body_small_semi(context),),
                    SizedBox(height: 12,),
                    Container(
                      width: screenWidth,
                      height: 144,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: customColors.primary
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),

                      ),
                    )
                  ],
                ),



                SizedBox(height: 24,),


                SizedBox(height: 24,),





                ElevatedButton(
                  onPressed: showNotification,
                  child: Text('Show Notification'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ButtonPrimary(
                    function: () {
                      print("Button pressed");
                      //function 은 상황에 맞게 재 정의 할 것.
                    },
                    title: '완료',
                    // 버튼 안에 들어갈 텍스트.
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(), // 네비게이션 바
    );
  }
}
