import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../util/box_shadow_styles.dart';
import '../components/custom_app_bar.dart';

class CourseDetailPage extends StatelessWidget {
  final String title; // 섹션 제목 전달

  const CourseDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: CustomAppBar_2depth_1(title: '코스 상세'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Course title and details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('주제가 들어감', style: body_large_semi(context)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconTextRow(icon: Icons.timer, text: '30분'),
                                    const SizedBox(width: 12),
                                    IconTextRow(icon: Icons.star, text: '쉬움'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '숲에서 다양한 미션을 수행하고 고향에 대한 깊은 이해를 얻어야 해요. 각 활동을 완료할 때마다 힌트를 얻고, 최종적으로 고향 이야기를 완성하세요.',
                                  style: body_small(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 36),
                          Image.network(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF8Akju0ZLzK2NUAJp0jai5DB_Ut3EkGDkww&s",
                            width: 106,
                            height: 98,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Learning Mission Section
                      MissionSection(
                        title: '학습 미션',
                        missions: [
                          '제목 유추',
                          '내용 요약',
                          '추가 학습',
                          '질문 작성하기',
                          '핵심 내용 질문',
                          '추가 학습',
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Learning Effect Section
                      EffectSection(
                        title: '학습 효과',
                        effects: [
                          '핵심 정보를 파악하는 능력향상',
                          '텍스트를 깊이 이해하고 개인적인 관점을 형성',
                          '정보를 체계적으로 정리하는 능력 배양',
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Start button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: customColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: BoxShadowStyles.shadow1(context),
                ),
                child: Center(
                  child: Text(
                    '시작하기',
                    style: body_medium_semi(context).copyWith(color: customColors.neutral100),
                  ),
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
  final List<String> missions;

  const MissionSection({super.key, required this.title, required this.missions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_xsmall_semi(context)),
          const SizedBox(height: 10),
          // Wrap widget for the missions list
          Wrap(
            spacing: 12, // Horizontal space between items
            runSpacing: 12, // Vertical space between lines of items
            children: List.generate((missions.length / 2).ceil(), (index) {
              final firstMissionIndex = index * 2;
              final secondMissionIndex = firstMissionIndex + 1;
              return Row(
                children: [
                  // Make each MissionItem take half the space using Expanded
                  Expanded(child: MissionItem(mission: missions[firstMissionIndex])),
                  if (secondMissionIndex < missions.length)
                    const SizedBox(width: 12), // Adding some space between the items
                  if (secondMissionIndex < missions.length)
                    Expanded(child: MissionItem(mission: missions[secondMissionIndex])),
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
        Icon(Icons.circle, size: 6),
        const SizedBox(width: 8),
        Text(mission, style: body_xsmall(context)),
      ],
    );
  }
}

class EffectSection extends StatelessWidget {
  final String title;
  final List<String> effects;

  const EffectSection({super.key, required this.title, required this.effects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: ShapeDecoration(
        color: Theme.of(context).extension<CustomColors>()!.neutral90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        Icon(Icons.circle, size: 6),
        const SizedBox(width: 8),
        Text(effect, style: body_xsmall(context)),
      ],
    );
  }
}
