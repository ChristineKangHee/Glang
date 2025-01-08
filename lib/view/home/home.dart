/// File: home.dart
/// Purpose: 메인 화면
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/util/gradients.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import '../../model/section_data.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../course/popup_component.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(gradient: AppGradients.whiteToGrey(customColors)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //TODO: 인사말 위젯
                GreetingSection(name: name),
                SizedBox(height: 24,),

                //TODO: 진행 중인 학습 위젯
                ProgressSection(data: data),
                SizedBox(height: 24,),

                //TODO: 인기 게시물 위젯
                HotPost(customColors: customColors),
                SizedBox(height: 24,),

                //TODO: 이번달 학습 기록 위젯
                LearningSection(customColors: customColors),

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

class LearningSection extends StatelessWidget {
  LearningSection({
    super.key,
    required this.customColors,
  });
  final CustomColors customColors;
  final imageLink_1 = "assets/icons/record_time.svg";
  final imageLink_2 = "assets/icons/record_mission.svg";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("이번달 학습 기록", style: body_small_semi(context),),
        SizedBox(height: 12,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LearningSection_Card(customColors: customColors, imageLink: imageLink_1, title: "4시간 30분", subtitle: "학습 시간",),
            LearningSection_Card(customColors: customColors, imageLink: imageLink_2, title: "32개", subtitle: "완료한 미션",),
          ],
        ),
      ],
    );
  }
}

class LearningSection_Card extends StatelessWidget {
  const LearningSection_Card({
    super.key,
    required this.customColors,
    required this.imageLink,
    required this.title,
    required this.subtitle,
  });

  final CustomColors customColors;
  final imageLink;
  final title;
  final subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 170,
        height: 142,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: SvgPicture.asset(
                '$imageLink',
              ),
            ),
            SizedBox(height: 8,),
            Text("$title", style: heading_medium(context).copyWith(color: customColors.neutral30),),
            Text("$subtitle", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),),
          ],
        ),
      ),
    );
  }
}

class ProgressSection extends StatelessWidget {
  const ProgressSection({
    super.key,
    required this.data,
  });

  final SectionData data;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column( // 나중에 섹션 분리할 것
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("안녕하세요, $name님!", style: heading_medium(context),),
        Text("오늘의 학습 목표를 달성해 보세요!", style: body_xsmall(context),),
      ],
    );
  }
}

class HotPost extends StatelessWidget {
  const HotPost({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("인기 게시물", style: body_small_semi(context),),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/notification"),
              child: Row(
                children: [
                  Text("더보기", style: body_xxsmall_semi(context),),
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomCard(customColors: customColors),
              CustomCard(customColors: customColors),
              CustomCard(customColors: customColors),
            ],
          ),
        ),
      ],
    );
  }
}
// 인기 게시물 부분 Card
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          width: 262,
          height: 109,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //텍스트 세로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.start, //텍스트 가로 시작점
            children: [
              Text("TOPIC 시험 준비", style: body_xsmall_semi(context), overflow: TextOverflow.ellipsis,),
              SizedBox(height: 4,),
              Text("엄청나게 긴 텍스트", style: body_xxsmall(context), overflow: TextOverflow.ellipsis,),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: customColors.neutral60,),
                      SizedBox(width: 4,),
                      Text("67", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),),
                      SizedBox(width: 8,),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: customColors.neutral60,),
                      SizedBox(width: 4,),
                      Text("203", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),),
                      SizedBox(width: 8,),
                    ],
                  ),
                ],
              )
            ],
          ),
          ),
    );
  }
}
