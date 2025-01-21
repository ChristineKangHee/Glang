/// File: home.dart
/// Purpose: 메인 화면
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-09 by 박민준

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/util/gradients.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:readventure/view/home/user_service.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends ConsumerWidget { // ConsumerWidget으로 변경
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? userId = _auth.currentUser?.uid;
    final userName = ref.watch(userNameProvider); // 사용자 이름 상태 구독

    if (userId != null) {
      ref.read(userNameProvider.notifier).fetchUserName(userId);
    }


    final data = SectionData(
      section: 1,
      title: "초급 코스",
      subdetailTitle: ["읽기 도구의 필요성"],
      textContents: ["이 섹션에서는 학습 목표를 달성하는 방법을 배웁니다."],
      achievement: ['0'],
      totalTime: ['30'],
      difficultyLevel: ["쉬움"],
      imageUrls: ['https://picsum.photos/250?image=9',],
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
            padding: EdgeInsets.all(16.0.r),
            decoration: BoxDecoration(gradient: AppGradients.whiteToGrey(customColors)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //TODO: 인사말 위젯
                GreetingSection(name: userName),
                SizedBox(height: 24.h,),

                //TODO: 진행 중인 학습 위젯
                ProgressSection(data: data),
                SizedBox(height: 24.h,),

                // //TODO: 인기 게시물 위젯
                // HotPostSection(customColors: customColors),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("출석 체크", style: body_small_semi(context),),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: customColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                        child: AttendanceWidget()
                    ),
                  ],
                ),
                SizedBox(height: 24.h,),

                //TODO: 출석체크 위젯


                //TODO: 이번달 학습 기록 위젯
                InkWell(
                  onTap: () => Navigator.pushNamed(context, "/mypage/statistics"),
                  child: LearningSection(customColors: customColors),
                ),

                // ElevatedButton(
                //   onPressed: showNotification,
                //   child: Text('Show Notification'),
                // ),

                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/brmain"),
                  child: Text('읽기 전 코스 이동'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/rdmain"),
                  child: Text('읽기 중 코스 이동'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/armain"),
                  child: Text('읽기 후 코스 이동'),
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

class AttendanceWidget extends StatelessWidget {
  final List<AttendanceDay> attendanceDays = [
    AttendanceDay(date: '1/19', status: AttendanceStatus.missed, xp: 0),
    AttendanceDay(date: '1/20', status: AttendanceStatus.missed, xp: 0),
    AttendanceDay(date: '1/21', status: AttendanceStatus.completed, xp: 10),
    AttendanceDay(date: '1/22', status: AttendanceStatus.upcoming, xp: 10),
    AttendanceDay(date: '1/23', status: AttendanceStatus.upcoming, xp: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: attendanceDays.map((day) => AttendanceDayWidget(day)).toList(),
    );
  }
}

class AttendanceDay {
  final String date;
  final AttendanceStatus status;
  final int xp;

  AttendanceDay({required this.date, required this.status, required this.xp});
}

enum AttendanceStatus { missed, completed, upcoming }

class AttendanceDayWidget extends StatelessWidget {
  final AttendanceDay day;

  const AttendanceDayWidget(this.day);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    Color? iconColor;
    Color? textColor;
    Color? backgroundColor;
    String iconText;

    switch (day.status) {
      case AttendanceStatus.missed:
        iconColor = customColors.neutral60;
        textColor = customColors.neutral60;
        backgroundColor = customColors.neutral80;
        iconText = 'X';
        break;
      case AttendanceStatus.completed:
        iconColor = customColors.primary;
        textColor = customColors.primary;
        backgroundColor = Colors.blue.shade100;
        iconText = '♥';
        break;
      case AttendanceStatus.upcoming:
        iconColor = customColors.neutral60;
        textColor = customColors.neutral60;
        backgroundColor = Colors.grey.shade100;
        iconText = '♥';
        break;
    }

    return Column(
      children: [
        Text(
          day.date,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        SizedBox(height: 4),
        CircleAvatar(
          radius: 20,
          backgroundColor: backgroundColor,
          child: Text(
            iconText,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          day.status == AttendanceStatus.missed ? '미출석' : '+${day.xp}xp',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
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
        SizedBox(height: 12.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: LearningSection_Card(customColors: customColors, imageLink: imageLink_1, title: "4시간 30분", subtitle: "학습 시간",)),
            SizedBox(width: 20,),
            Expanded(child: LearningSection_Card(customColors: customColors, imageLink: imageLink_2, title: "32개", subtitle: "완료한 미션",)),
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
        // width: 170.5.w,
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
        SizedBox(height: 12.h,),
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

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Column( // 나중에 섹션 분리할 것
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("안녕하세요, $name님!", style: heading_medium(context),),
        SizedBox(height: 4.h,),
        Text("오늘의 학습 목표를 달성해 보세요!", style: body_xsmall(context),),
      ],
    );
  }
}

class HotPostSection extends StatelessWidget {
  const HotPostSection({
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
        SizedBox(height: 12.h,),
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
          width: 262.w,
          height: 109.h,
          padding: EdgeInsets.all(10.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //텍스트 세로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.start, //텍스트 가로 시작점
            children: [
              Text("TOPIC 시험 준비", style: body_xsmall_semi(context), overflow: TextOverflow.ellipsis,),
              SizedBox(height: 4.h,),
              Text("엄청나게 긴 텍스트", style: body_xxsmall(context), overflow: TextOverflow.ellipsis,),
              SizedBox(height: 8.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: customColors.neutral60,),
                      SizedBox(width: 4.w,),
                      Text("67", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),),
                      SizedBox(width: 8.w,),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: customColors.neutral60,),
                      SizedBox(width: 4.w,),
                      Text("203", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),),
                      SizedBox(width: 8.w,),
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
