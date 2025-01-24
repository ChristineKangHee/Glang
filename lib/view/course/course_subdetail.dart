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
import '../../util/box_shadow_styles.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../feature/before_read/GA_01_01_cover_research/CR_learning.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseDetailPage extends StatelessWidget {
  final String title; // 코스 제목
  final String time; // 소요 시간
  final String level; // 난이도
  final String description; // 코스 설명
  final List<String> mission; // 학습 미션 리스트
  final List<String> effect; // 학습 효과 리스트

  const CourseDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.mission,
    required this.effect,
    required this.time,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '코스 상세'), // 사용자 정의 앱바
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16), // 외부 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 코스 제목 및 상세 정보
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: body_large_semi(context)), // 코스 제목
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconTextRow(icon: Icons.timer, text: time + '분'), // 시간 아이콘과 텍스트
                                    const SizedBox(width: 12),
                                    IconTextRow(icon: Icons.star, text: level), // 난이도 아이콘과 텍스트
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  description,
                                  style: body_small(context), // 설명 텍스트 스타일
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 36),
                          SvgPicture.asset(
                            'assets/images/charactor.svg', // 네트워크 이미지
                            width: 106,
                            height: 98,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MissionSection(
                        title: '학습 미션', // 미션 섹션 제목
                        missions: mission, // 미션 리스트
                      ),
                      const SizedBox(height: 20),
                      EffectSection(
                        title: '학습 효과', // 학습 효과 섹션 제목
                        effects: effect, // 학습 효과 리스트
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 시작 버튼
              Container(
                width: MediaQuery.of(context).size.width,
                child: ButtonPrimary(
                  function: () {
                    print("시작하기");
                    //function 은 상황에 맞게 재 정의 할 것.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CRLearning(
                          
                        ), // BrMain으로 이동
                      ),
                    );
                  },
                  title: '시작하기',
                  // 버튼 안에 들어갈 텍스트.
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
