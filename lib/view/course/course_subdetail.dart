/// File: lib/view/course/course_subdetail.dart
/// Purpose: 사용자에게 각 학습에 대한 코스 상세 정보를 보여줌
/// Author: 강희
/// Created: 2024-01-04
/// Last Modified: 2025-08-13 by ChatGPT (다국어 적용 + 새 StageData 타입 반영)

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
import 'package:easy_localization/easy_localization.dart' hide tr;

// CHANGED: tr 유틸
import '../../localization/tr.dart';
import '../../model/stage_data.dart'; // StageData, StageStatus

class CourseDetailPage extends ConsumerWidget {
  final StageData stage; // 스테이지 전체를 받음
  const CourseDetailPage({Key? key, required this.stage}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = context.glangLocale; // CHANGED

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
                      // 스테이지 정보
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CHANGED: 다국어
                                Text(tr(stage.subdetailTitle, locale), style: body_large_semi(context)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconTextRow(
                                      icon: Icons.timer,
                                      text: 'time_minutes'.tr(args: [stage.totalTime.toString()]),
                                    ),
                                    const SizedBox(width: 12),
                                    // CHANGED: 난이도 다국어
                                    IconTextRow(icon: Icons.star, text: tr(stage.difficultyLevel, locale)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // CHANGED: 본문 다국어
                                Text(
                                  tr(stage.textContents, locale),
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
                      // CHANGED: missions/effects 다국어 리스트
                      MissionSection(title: 'missions_title'.tr(), missions: trList(stage.missions, locale)),
                      const SizedBox(height: 20),
                      EffectSection(title: 'effects_title'.tr(), effects: trList(stage.effects, locale)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 시작 버튼
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ButtonPrimary_noPadding(
                  function: () {
                    // 현재 스테이지 ID를 Riverpod에 설정
                    ref.read(selectedStageIdProvider.notifier).state = stage.stageId;

                    if (stage.activityCompleted["beforeReading"] == true &&
                        stage.activityCompleted["duringReading"] == false) {
                      // 읽기 전 완료 → 읽기 중
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RdBefore()));
                    } else if (stage.activityCompleted["duringReading"] == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'LearningActivitiesPage'),
                          builder: (context) => LearningActivitiesPage(),
                        ),
                      );
                    } else {
                      // 기본: 읽기 전
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CRLearning()));
                    }
                  },
                  title: 'start_button'.tr(),
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
  final IconData icon;
  final String text;

  const IconTextRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Text(text, style: body_xsmall_semi(context)),
      ],
    );
  }
}

class MissionSection extends StatelessWidget {
  final String title;
  final List<String> missions; // CHANGED: 이미 trList로 변환된 List<String>을 받음

  const MissionSection({super.key, required this.title, required this.missions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_xsmall_semi(context)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate((missions.length / 2).ceil(), (index) {
              final first = index * 2;
              final second = first + 1;
              return Row(
                children: [
                  Expanded(child: MissionItem(mission: missions[first])),
                  if (second < missions.length) const SizedBox(width: 12),
                  if (second < missions.length) Expanded(child: MissionItem(mission: missions[second])),
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
  final String mission;
  const MissionItem({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 6),
        const SizedBox(width: 8),
        Text(mission, style: body_xsmall(context)),
      ],
    );
  }
}

class EffectSection extends StatelessWidget {
  final String title;
  final List<String> effects; // CHANGED: 이미 trList로 변환된 List<String>

  const EffectSection({super.key, required this.title, required this.effects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_xsmall_semi(context)),
          const SizedBox(height: 10),
          ...effects.map((effect) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: EffectItem(effect: effect),
          )),
        ],
      ),
    );
  }
}

class EffectItem extends StatelessWidget {
  final String effect;
  const EffectItem({super.key, required this.effect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 6),
        const SizedBox(width: 8),
        Text(effect, style: body_xsmall(context)),
      ],
    );
  }
}
