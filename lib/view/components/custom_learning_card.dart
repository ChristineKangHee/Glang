import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/util/box_shadow_styles.dart';
import 'package:readventure/theme/font.dart';
import '../course/course_main.dart';
import '../course/course_subdetail.dart';
import '../course/section.dart';

class SectionData {
  final Color color;
  final Color colorOscuro;
  final int etapa;
  final int section;
  final String title;
  final String sectionDetail;
  final List<String> subdetailTitle;
  final List<String> totalTime;
  final List<String> achievement;
  final List<String> difficultyLevel;
  final List<String> textContents;
  final List<String> imageUrls;
  final List<List<String>> missions;
  final List<List<String>> effects;
  final List<String> status; // New status list to track button state

  SectionData({
    required this.color,
    required this.colorOscuro,
    required this.etapa,
    required this.section,
    required this.title,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.sectionDetail,
    required this.subdetailTitle,
    required this.textContents,
    required this.imageUrls,
    required this.missions,
    required this.effects,
    required this.status, // Initialize status
  });
}

class CustomLearningCard extends StatelessWidget {
  final SectionData data;
  const CustomLearningCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final index = 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: BoxShadowStyles.shadow1(context),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: body_xsmall_semi(context).copyWith(
                            color: customColors.neutral100),
                      ),
                      Text(
                        data.subdetailTitle[index],
                        style: body_large_semi(context).copyWith(
                            color: customColors.neutral100),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CourseDetailPage(
                                title: data.subdetailTitle[index],
                                time: data.totalTime[index].toString(),
                                level: data.difficultyLevel[index],
                                description: data.textContents[index],
                                imageUrl: data.imageUrls[index],
                                mission: data.missions[index],
                                effect: data.effects[index],
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.neutral100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      '시작하기',
                      style: body_xsmall_semi(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildIconWithText(context, Icons.check_circle,
                      data.achievement[index] + '%', customColors),
                  const SizedBox(width: 8), // Spacing between items
                  _buildIconWithText(
                      context, Icons.timer, data.totalTime[index] + '분',
                      customColors),
                  const SizedBox(width: 8), // Spacing between items
                  _buildIconWithText(
                      context, Icons.star, data.difficultyLevel[index],
                      customColors),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithText(BuildContext context, IconData icon, String text,
      CustomColors customColors) {
    return Row(
      children: [
        Icon(icon, color: customColors.neutral90, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: body_xsmall_semi(context).copyWith(
              color: customColors.neutral90),
        ),
      ],
    );
  }
}
