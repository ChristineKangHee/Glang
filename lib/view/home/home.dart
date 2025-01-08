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
import '../../model/section_data.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../course/popup_component.dart';
import 'example.dart';

class MyHomePage extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final name = "제로";
    final data = SectionData(
      section: 1,
      title: "예제 섹션",
      subdetailTitle: ["소제목 1"],
      textContents: ["이 섹션에서는 학습 목표를 달성하는 방법을 배웁니다."],
      achievement: ['10'],
      totalTime: ['30'],
      difficultyLevel: ["쉬움"],
      imageUrls: ['https://www.google.com/url?sa=i&url=https%3A%2F%2Fm.health.chosun.com%2Fsvc%2Fnews_view.html%3Fcontid%3D2023071701758&psig=AOvVaw15uCYdRE77x_VcSo5nt8IE&ust=1736318472714000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCMjLv8CA44oDFQAAAAAdAAAAABAE',],
      missions: [['미션 1-1', '미션 1-2', '미션 1-3', '미션 1-4', '미션 1-5', '미션 1-6'],],
      effects: [['미션 1-1', '미션 1-2', '미션 1-3',],],
      status: ["start",],
      sectionDetail: '중급 코스의 설명 내용입니다.', // 상태값 예시
    );


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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("안녕하세요, $name님!", style: heading_medium(context),),
                    Text("오늘의 학습 목표를 달성해 보세요!", style: body_xsmall(context),),
                  ],
                ),
                SizedBox(height: 24,),
                //TODO: 진행 중인 학습 위젯
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("진행 중인 학습", style: body_small_semi(context),),
                    SectionPopup(
                      title: data.title,
                      subTitle: data.subdetailTitle[0],
                      time: data.totalTime[0],
                      level: data.difficultyLevel[0],
                      description: data.textContents[0],
                      imageUrl: data.imageUrls[0],
                      missions: data.missions[0],
                      effects: data.effects[0],
                      achievement: data.achievement[0],
                      status: data.status[0],
                    ),
                  ],
                ),

                SizedBox(height: 24,),
                //TODO: 인기 게시물 위젯
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("인기 게시물", style: body_small_semi(context),),
                        Row(
                          children: [
                            Text("더보기", style: body_xxsmall_semi(context),),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Card(
                            child: Container(
                                width: 262,
                                height: 109,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("data", style: body_xsmall_semi(context),)
                                  ],
                                ),
                                ),
                          ),
                          Card(
                            child: SizedBox(width: 262, height: 109,),
                          ),
                          Card(
                            child: SizedBox(width: 262, height: 109,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24,),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("이번달 학습 기록", style: body_small_semi(context),),
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          child: SizedBox(width: 170, height: 142,),
                        ),
                        Card(
                          child: SizedBox(width: 170, height: 142,),
                        ),
                      ],
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: showNotification,
                  child: Text('Show Notification'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ButtonPrimary(
                    function: () {
                      print("Button pressed");
                      Navigator.pushNamed(context, "/example");
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
