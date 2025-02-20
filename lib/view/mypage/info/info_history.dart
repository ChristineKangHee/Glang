/// File: history.dart
/// Purpose: 학습 기록을 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-02-20 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../course/course_subdetail.dart';

/// InfoHistory: Displays the history page with a list of courses and stages.
class InfoHistory extends ConsumerWidget {
  const InfoHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_4(title: "기록"),
      body: RecordPage(),
    );
  }
}

/// RecordPage: Displays the stages for each course.
class RecordPage extends ConsumerWidget {
  final List<Map<String, dynamic>> course1Stages = [
    {
      'name': '스테이지 1',
      'missions': ['미션 1', '미션 2', '미션 3'],
    },
    {
      'name': '스테이지 2',
      'missions': ['미션 A', '미션 B'],
    },
  ];
  final List<Map<String, dynamic>> course2Stages = [];
  final List<Map<String, dynamic>> course3Stages = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    List<Widget> buildCourseSection(String courseTitle, List<Map<String, dynamic>> stages) {
      if (stages.isEmpty) return []; // 코스가 없으면 아무것도 표시하지 않음

      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            courseTitle,
            style: heading_xxsmall(context).copyWith(color: customColors.neutral0),
          ),
        ),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final double leftMargin = index == 0 ? 16.0 : 8.0;
              final double rightMargin = index == stages.length - 1 ? 16.0 : 8.0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MissionPage(
                        stageName: stage['name'],
                        missions: stage['missions'],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(
                    left: leftMargin,
                    right: rightMargin,
                  ),
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text(stage['name'], style: body_large_semi(context),)),
                  ),
                ),
              );
            },
          ),
        ),
      ];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...buildCourseSection('코스1', course1Stages),
          ...buildCourseSection('코스2', course2Stages),
          ...buildCourseSection('코스3', course3Stages),
        ],
      ),
    );
  }
}

/// MissionPage: Displays detailed information about a specific stage and its missions.
class MissionPage extends ConsumerStatefulWidget {
  final String stageName;
  final List<String> missions;

  MissionPage({required this.stageName, required this.missions});

  @override
  _MissionPageState createState() => _MissionPageState();
}

class _MissionPageState extends ConsumerState<MissionPage> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar:  CustomAppBar_2depth_4(title: "기록"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Info Section
          Container(
            padding: EdgeInsets.all(16),
            color: customColors.neutral100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('스테이지 제목', style: body_large_semi(context)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconTextRow(icon: Icons.timer, text: '10분'),
                            const SizedBox(width: 12),
                            IconTextRow(icon: Icons.star, text: '난이도 3'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Circular IconButton for download
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: customColors.neutral100,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: customColors.neutral80!,
                                width: 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.file_download_outlined),
                              iconSize: 24,
                              color: customColors.neutral30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Circular IconButton for import_contacts_outline
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: customColors.primary,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.import_contacts_outlined),
                            iconSize: 24,
                            color: customColors.neutral100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '여기에 스테이지 내용이 들어갑니다. 이 부분은 설명을 위한 텍스트입니다.',
                  style: body_small(context),
                ),
              ],
            ),
          ),
          // Missions List
          // Missions List
          Expanded(
            child: ListView.builder(
              itemCount: widget.missions.length,
              itemBuilder: (context, index) {
                String item = widget.missions[index];

                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(
                    top: index == 0 ? 16.0 : 8.0, // Top margin set to 16 for the first item
                    bottom: 8,
                    left: 16,
                    right: 16,
                  ),
                  decoration: ShapeDecoration(
                    color: customColors.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item,
                              style: body_medium_semi(context).copyWith(color: customColors.primary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '미션 내용이 들어갑니다.',
                              style: body_xsmall(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: customColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '상세보기',
                            style: body_xsmall_semi(context).copyWith(color: customColors.neutral100),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
