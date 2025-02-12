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
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import '../../model/section_data.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../../viewmodel/section_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../course/popup_component.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/user_service.dart';

import 'attendance/attendance_model.dart';
import 'attendance/attendance_provider.dart';

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
    final sectionAsync = ref.watch(sectionProvider); // ✅ FutureProvider 사용

    if (userId != null) {
      ref.read(userNameProvider.notifier).fetchUserName();
    }

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_Logo(),
      body: SafeArea(
        child: userId == null
          ? Center(child: Text("로그인이 필요합니다"),)
        :  sectionAsync.when(
          data: (sections){
            StageData? findFirstInProgress(List<SectionData> sections) {
              try {
                // 조건을 만족하는 첫 번째 StageData 반환
                return sections
                    .expand((s) => s.stages)
                    .firstWhere((stage) => stage.status == StageStatus.inProgress);
              } catch (e) {
                // StateError가 발생하면, 진행 중인 스테이지가 없다는 뜻이므로 null 반환
                return null;
              }
            }
            final ongoingStage = findFirstInProgress(sections);
            if (ongoingStage != null) {
              // 진행 중인 스테이지 표시
            } else {
              // 없음
            }

            return SingleChildScrollView(
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
                      if (ongoingStage != null) ProgressSection(data: ongoingStage), // 🔹 `ProgressSection`에서 `StageData` 사용
                      SizedBox(height: 24.h,),

                      // HotPostSection(customColors: customColors),
                      //TODO: 출석체크 위젯
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("출석 체크", style: body_small_semi(context),),
                          SizedBox(height: 12,),
                          Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: customColors.neutral100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AttendanceWidget()
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h,),

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
              );
          },
          loading: () => Center(child: CircularProgressIndicator()), // ✅ 로딩 중
          error: (error, stack) => Center(child: Text("데이터 로딩 실패: $error")), // ✅ 에러 처리
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(), // 네비게이션 바
    );
  }
}

class AttendanceWidget extends ConsumerWidget {
  const AttendanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceProvider);
    return attendanceAsync.when(
      data: (attendanceDays) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: attendanceDays
            .map((day) => AttendanceDayWidget(day))
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("오류 발생: $error")),
    );
  }
}

class AttendanceDayWidget extends StatelessWidget {
  final AttendanceDay day;

  const AttendanceDayWidget(this.day);

  String formatDateForDisplay(String storedDate) {
    // storedDate는 "2025-2-2" 형태라고 가정합니다.
    // '-'로 분할한 후, 두 번째(월)와 세 번째(일) 부분만 사용하여 "/"로 결합
    final parts = storedDate.split('-');
    if (parts.length == 3) {
      return "${parts[1]}/${parts[2]}";
    }
    return storedDate; // 예상치 못한 경우 그대로 반환
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    Color? iconColor;
    Color? textColor;
    Color? backgroundColor;
    Color? borderColor;
    IconData iconData;

    switch (day.status) {
      case AttendanceStatus.missed:
        iconColor = customColors.neutral60;
        textColor = customColors.neutral60;
        backgroundColor = customColors.neutral80;
        borderColor=customColors.neutral60;
        iconData = Icons.close_rounded; // Icon for missed
        break;
      case AttendanceStatus.completed:
        iconColor = customColors.primary;
        textColor = customColors.primary;
        backgroundColor = customColors.primary10;
        borderColor=customColors.primary;
        iconData = Icons.favorite; // Icon for completed
        break;
      case AttendanceStatus.upcoming:
        iconColor = customColors.neutral60;
        textColor = customColors.neutral60;
        backgroundColor = customColors.neutral90;
        borderColor=customColors.neutral60;
        iconData = Icons.favorite; // Icon for upcoming
        break;
    }

    return Column(
      children: [
        Text(
          formatDateForDisplay(day.date),
          style: body_xxsmall(context).copyWith(color: customColors.neutral30,),
        ),
        SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: borderColor??Colors.grey,
            ),
          ),
          child: Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        // Text(
        //   day.status == AttendanceStatus.missed ? '미출석' : '+${day.xp}xp',
        //   style: body_xxsmall(context).copyWith(color: textColor,),
        // ),
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
        Text("이번달 기록", style: body_small_semi(context),),
        SizedBox(height: 12.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: LearningSection_Card(customColors: customColors, imageLink: imageLink_1, title: "4시간 30분", subtitle: "읽은 시간",)),
            SizedBox(width: 16,),
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

  final StageData data; // 🔹 `SectionData` → `StageData` 로 변경

  // enum → string 변환 함수 (StageData에도 존재할 수 있으나 여기선 간단히 작성)
  String stageStatusToString(StageStatus status) {
    switch (status) {
      case StageStatus.locked:
        return 'locked';
      case StageStatus.inProgress:
        return 'inProgress';
      case StageStatus.completed:
        return 'completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("진행 중인 스테이지", style: body_small_semi(context),),
        SizedBox(height: 12.h,),
        SectionPopup(stage: data),
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
        Text("오늘의 목표를 달성해 보세요!", style: body_xsmall(context),),
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
