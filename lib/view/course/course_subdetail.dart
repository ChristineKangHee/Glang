/// 파일: course_subdetail.dart
/// 목적: 사용자에게 각 학습에 대한 코스 상세 정보를 보여줌
/// 작성자: 강희
/// 생성일: 2024-01-04
/// 마지막 수정: 2025-01-06 by 강희

import 'package:flutter/material.dart';
import 'package:readventure/view/course/section.dart';
import 'package:readventure/view/feature/before_read/GA_01_01_cover_research/CR_main.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../model/section_data.dart';
import '../../util/box_shadow_styles.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../feature/after_read/choose_activities.dart';
import '../feature/before_read/GA_01_01_cover_research/CR_learning.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feature/reading/GA_02/RD_before.dart';
import '../home/stage_provider.dart';
import 'package:easy_localization/easy_localization.dart';

// course_subdetail.dart
class CourseDetailPage extends ConsumerWidget {
  final StageData stage; // 스테이지 전체를 받음

  const CourseDetailPage({Key? key, required this.stage}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: 'stage_detail_title'.tr()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 예: 스테이지 정보 표시
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stage.subdetailTitle, style: body_large_semi(context)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconTextRow(
                                      icon: Icons.timer,
                                      text: 'time_minutes'.tr(args: [stage.totalTime.toString()]), // ***
                                    ),
                                    const SizedBox(width: 12),
                                    IconTextRow(icon: Icons.star, text: stage.difficultyLevel),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  stage.textContents,
                                  style: body_small(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SvgPicture.asset(
                            'assets/images/character_total.svg',
                            width: 106,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MissionSection(title: 'missions_title'.tr(), missions: stage.missions), // ***
                      const SizedBox(height: 20),
                      EffectSection(title: 'effects_title'.tr(), effects: stage.effects), // ***
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 시작 버튼
              Container(
                width: MediaQuery.of(context).size.width,
                child: ButtonPrimary_noPadding(
                  function: () {
                    // ⭐ 핵심: 현재 스테이지 ID를 Riverpod에 설정
                    ref.read(selectedStageIdProvider.notifier).state = stage.stageId;

                    if (stage.activityCompleted["beforeReading"] == true &&
                        stage.activityCompleted["duringReading"] == false) {
                      // 읽기 전 완료 → 읽기 중 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RdBefore()),
                      );
                    } else if (stage.activityCompleted["duringReading"] == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: 'LearningActivitiesPage'),
                          builder: (context) => LearningActivitiesPage(),
                        ),
                      );
                    } else {
                      // 기본적으로 읽기 전 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CRLearning()),
                      );
                    }

                    // // 그리고 CRLearning 화면으로 이동
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const CRLearning()),
                    // );
                  },
                  title: 'start_button'.tr(), // ***
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class IconTextRow extends StatelessWidget {
  final IconData icon; // 아이콘 데이터
  final String text; // 텍스트

  const IconTextRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon), // 아이콘 표시
        const SizedBox(width: 4),
        Text(text, style: body_xsmall_semi(context)), // 텍스트 표시
      ],
    );
  }
}

class MissionSection extends StatelessWidget {
  final String title; // 섹션 제목
  final List<String> missions; // 미션 리스트

  const MissionSection({super.key, required this.title, required this.missions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), // 섹션 여백
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90, // 배경 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 모서리 둥글기
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_xsmall_semi(context)), // 섹션 제목
          const SizedBox(height: 10),
          Wrap(
            spacing: 12, // 항목 간 가로 간격
            runSpacing: 12, // 줄 간 세로 간격
            children: List.generate((missions.length / 2).ceil(), (index) {
              final firstMissionIndex = index * 2; // 첫 번째 미션 인덱스
              final secondMissionIndex = firstMissionIndex + 1; // 두 번째 미션 인덱스
              return Row(
                children: [
                  Expanded(child: MissionItem(mission: missions[firstMissionIndex])), // 첫 번째 미션
                  if (secondMissionIndex < missions.length)
                    const SizedBox(width: 12), // 항목 간 간격
                  if (secondMissionIndex < missions.length)
                    Expanded(child: MissionItem(mission: missions[secondMissionIndex])), // 두 번째 미션
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MissionItem extends StatelessWidget {
  final String mission; // 개별 미션 내용

  const MissionItem({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6), // 작은 원 아이콘
        const SizedBox(width: 8),
        Text(mission, style: body_xsmall(context)), // 미션 텍스트
      ],
    );
  }
}

class EffectSection extends StatelessWidget {
  final String title; // 섹션 제목
  final List<String> effects; // 학습 효과 리스트

  const EffectSection({super.key, required this.title, required this.effects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), // 섹션 여백
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90, // 배경 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 모서리 둥글기
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_xsmall_semi(context)), // 섹션 제목
          const SizedBox(height: 10),
          ...effects.map((effect) => Padding(
            padding: const EdgeInsets.only(bottom: 10), // 항목 간 간격
            child: EffectItem(effect: effect), // 개별 학습 효과 항목
          )),
        ],
      ),
    );
  }
}

class EffectItem extends StatelessWidget {
  final String effect; // 개별 학습 효과 내용

  const EffectItem({super.key, required this.effect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6), // 작은 원 아이콘
        const SizedBox(width: 8),
        Text(effect, style: body_xsmall(context)), // 학습 효과 텍스트
      ],
    );
  }
}
