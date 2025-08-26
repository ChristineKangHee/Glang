/// File: lib/view/home/home.dart
/// Purpose: 메인 화면
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-08-13 by ChatGPT (다국어 구조 호환 + 타입 정합성 보정)

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/util/gradients.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:readventure/view/home/stage_provider.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import '../../model/section_data.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/notification_controller.dart';
import '../../viewmodel/section_provider.dart'; // (옵션 A 적용된) 섹션 FutureProvider
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../course/popup_component.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/user_service.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'attendance/attendance_model.dart';
import 'attendance/attendance_provider.dart';

// CHANGED: StageData/StageStatus 타입을 명시적으로 import
import '../../model/stage_data.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final customColors = ref.watch(customColorsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? userId = _auth.currentUser?.uid;
    final userName = ref.watch(userNameProvider);
    final sectionAsync = ref.watch(sectionProvider); // ✅ (옵션 A) 섹션 로딩

    if (userId != null) {
      ref.read(userNameProvider.notifier).fetchUserName();
    }

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: customColors.neutral90,
        appBar: CustomAppBar_Logo(),
        body: SafeArea(
          child: userId == null
              ? Center(child: Text("need_login".tr()))
              : sectionAsync.when(
            data: (sections) {
              // 진행 중 스테이지 탐색 (null-safe)
              StageData? findFirstInProgress(List<SectionData> sections) {
                try {
                  return sections
                      .expand((s) => s.stages)
                      .firstWhere((stage) => stage.status == StageStatus.inProgress);
                } catch (_) {
                  return null;
                }
              }

              final ongoingStage = findFirstInProgress(sections);
              // ongoingStage UI는 아래 ProgressSection에서 스트림 버전으로 대체되므로 그대로 둠

              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0.r),
                  decoration: BoxDecoration(gradient: AppGradients.whiteToGrey(customColors)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 인사말
                      GreetingSection(name: userName),
                      SizedBox(height: 24.h),

                      // 진행 중 학습(스트림 기반)
                      Consumer(
                        builder: (context, ref, child) {
                          final stagesStream = ref.watch(stagesStreamProvider);
                          return stagesStream.when(
                            data: (stages) {
                              final ongoingStage = stages.firstWhereOrNull(
                                    (stage) => stage.status == StageStatus.inProgress,
                              );
                              if (ongoingStage != null) {
                                return ProgressSection(data: ongoingStage); // 🔹 StageData 사용
                              }
                              return const SizedBox.shrink();
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text("오류 발생: $error")),
                          );
                        },
                      ),
                      SizedBox(height: 24.h),

                      // 출석 위젯
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('attendance_title'.tr(), style: body_small_semi(context)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: customColors.neutral100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const AttendanceWidget(),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // 이번달 학습 기록
                      InkWell(
                        child: LearningSection(customColors: customColors),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text("데이터 로딩 실패: $error")),
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
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
        children: attendanceDays.map((day) => AttendanceDayWidget(day)).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('error_with_message'.tr(args: [error.toString()]))),
    );
  }
}

class AttendanceDayWidget extends StatelessWidget {
  final AttendanceDay day;
  const AttendanceDayWidget(this.day);

  String formatDateForDisplay(String storedDate) {
    final parts = storedDate.split('-');
    if (parts.length == 3) {
      return "${parts[1]}/${parts[2]}";
    }
    return storedDate;
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
        borderColor = customColors.neutral60;
        iconData = Icons.close_rounded;
        break;
      case AttendanceStatus.completed:
        iconColor = customColors.primary;
        textColor = customColors.primary;
        backgroundColor = customColors.primary10;
        borderColor = customColors.primary;
        iconData = Icons.favorite;
        break;
      case AttendanceStatus.upcoming:
        iconColor = customColors.neutral60;
        textColor = customColors.neutral60;
        backgroundColor = customColors.neutral90;
        borderColor = customColors.neutral60;
        iconData = Icons.favorite;
        break;
    }

    return Column(
      children: [
        Text(
          formatDateForDisplay(day.date),
          style: body_xxsmall(context).copyWith(color: customColors.neutral30),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: borderColor ?? Colors.grey),
          ),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class LearningSection extends ConsumerWidget {
  const LearningSection({super.key, required this.customColors});
  final CustomColors customColors;
  final String imageLink_1 = "assets/icons/record_time.svg";
  final String imageLink_2 = "assets/icons/record_mission.svg";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userLearningStatsProvider);

    return statsAsync.when(
      data: (data) {
        final int learningTimeSeconds = data['learningTime'] ?? 0;
        final int completedMissionCount = data['completedMissionCount'] ?? 0;

        final hours = learningTimeSeconds ~/ 3600;
        final minutes = (learningTimeSeconds % 3600) ~/ 60;
        final formattedTime = hours > 0
            ? 'time_format_hm'.tr(args: [hours.toString(), minutes.toString()])
            : 'time_format_m'.tr(args: [minutes.toString()]);

        final formattedMissionCount = 'count_format'.tr(args: [completedMissionCount.toString()]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('this_month_record'.tr(), style: body_small_semi(context)),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LearningSection_Card(
                    customColors: customColors,
                    imageLink: imageLink_1,
                    title: formattedTime,
                    subtitle: 'read_time'.tr(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LearningSection_Card(
                    customColors: customColors,
                    imageLink: imageLink_2,
                    title: formattedMissionCount,
                    subtitle: 'completed_missions'.tr(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('error_with_message'.tr(args: [error.toString()])),
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
  final String imageLink;   // CHANGED: 타입 명시
  final String title;       // CHANGED: 타입 명시
  final String subtitle;    // CHANGED: 타입 명시

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(imageLink),
            const SizedBox(height: 8),
            Text(title, style: heading_medium(context).copyWith(color: customColors.neutral30)),
            Text(subtitle, style: body_xsmall_semi(context).copyWith(color: customColors.neutral60)),
          ],
        ),
      ),
    );
  }
}

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key, required this.data});
  final StageData data; // 🔹 진행 중 스테이지

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('in_progress_stage'.tr(), style: body_small_semi(context)),
        SizedBox(height: 12.h),
        SectionPopup(stage: data), // 팝업 내부에서 다국어 처리됨
      ],
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key, required this.name});
  final String? name;

  @override
  Widget build(BuildContext context) {
    final safeName = (name ?? '').isEmpty ? '' : name!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('greeting_hello_name'.tr(args: [safeName]), style: heading_medium(context)),
        SizedBox(height: 4.h),
        Text('greeting_motivation'.tr(), style: body_xsmall(context)),
      ],
    );
  }
}

class HotPostSection extends StatelessWidget {
  const HotPostSection({super.key, required this.customColors});
  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('hot_posts'.tr(), style: body_small_semi(context)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/notification"),
              child: Row(
                children: [
                  Text('see_more'.tr(), style: body_xxsmall_semi(context)),
                  const Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 교체 후 (customColors 그대로 전달)
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
          mainAxisAlignment: MainAxisAlignment.center, // 텍스트 세로 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 가로 시작점
          children: [
            Text("TOPIC 시험 준비", style: body_xsmall_semi(context), overflow: TextOverflow.ellipsis),
            SizedBox(height: 4.h),
            Text("엄청나게 긴 텍스트", style: body_xxsmall(context), overflow: TextOverflow.ellipsis),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: customColors.neutral60),
                    SizedBox(width: 4.w),
                    Text("67", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60)),
                    SizedBox(width: 8.w),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: customColors.neutral60),
                    SizedBox(width: 4.w),
                    Text("203", style: body_xsmall_semi(context).copyWith(color: customColors.neutral60)),
                    SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
