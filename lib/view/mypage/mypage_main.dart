/// File: mypage_main.dart
/// Purpose: 마이페이지 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-08 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';
import 'package:d_chart/d_chart.dart';
import 'package:intl/intl.dart';

/// 마이페이지 메인 화면 위젯
/// - 상단 앱바, 하단 네비게이션 바, 컨텐츠
class MyPageMain extends ConsumerStatefulWidget {
  const MyPageMain({super.key});

  @override
  ConsumerState<MyPageMain> createState() => _MyPageMainState();
}

/// 마이페이지 메인 화면의 상태 관리 위젯
/// - SafeArea와 Scaffold 화면 구조를 설정
class _MyPageMainState extends ConsumerState<MyPageMain> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_MyPage(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                customColors.neutral100 ?? Colors.white, // 위쪽 흰색
                customColors.neutral90 ?? Colors.grey[300]!, // 아래쪽 회색
              ],
            ),
          ),
          child: const MyPageContent(), // 실제 화면 컨텐츠
        ),
        bottomNavigationBar: CustomNavigationBar(),
      ),
    );
  }
}

/// 마이페이지의 컨텐츠 본문
/// - 사용자 프로필, 학습 현황 및 통계
class MyPageContent extends StatelessWidget {
  const MyPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserProfileSection(), // 사용자 프로필 섹션
            const SizedBox(height: 40),
            const UserStatsSection(), // 사용자 경험치, 코스, 랭킹 표시
            const SizedBox(height: 24),
            // 학습 통계 카드
            InfoCard(
              title: '학습 통계',
              description: '일주일에 활동한 학습을 확인하세요!',
              child: const ProgressChart(),
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/statistics');
              },
            ),
            const SizedBox(height: 16),
            // 배지 카드
            InfoCard(
              title: '획득한 배지',
              child: const BadgeRow(),
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/badge');
              },
            ),
            const SizedBox(height: 16),
            // 저장된 학습 데이터 카드
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              title: '저장',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/saved');
              },
            ),
            const SizedBox(height: 16),
            // 학습 기록 카드
            InfoCard(
              leadingIcon: Icons.book,
              title: '학습 기록',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용자 프로필 섹션
/// - 프로필 이미지, 사용자 이름, 내 정보 수정
class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            image: const DecorationImage(
              image: NetworkImage("https://via.placeholder.com/100x100"),
              fit: BoxFit.fill,
            ),
            shape: CircleBorder(
              side: BorderSide(width: 3, color: customColors.neutral90 ?? Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('하나둘셋제로', style: heading_small(context)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/mypage/edit_profile');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: customColors.neutral90,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '내 정보 수정',
                    style: pretendardMedium(context).copyWith(
                      fontSize: 14,
                      color: customColors.neutral30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 사용자 경험치, 코스, 랭킹 통계 표시 섹션
class UserStatsSection extends StatelessWidget {
  const UserStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: StatBox(value: '1100', label: '경험치')),
        VerticalDivider(),
        Expanded(child: StatBox(value: '중급', label: '코스')),
        VerticalDivider(),
        Expanded(child: StatBox(value: '2위', label: '랭킹')),
      ],
    );
  }
}

/// 학습 통계 그래프 위젯
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    List<TimeData> series1 = [
      TimeData(domain: DateTime(2025, 1, 6), measure: 7),
      TimeData(domain: DateTime(2025, 1, 7), measure: 5),
      TimeData(domain: DateTime(2025, 1, 8), measure: 9),
      TimeData(domain: DateTime(2025, 1, 9), measure: 10),
      TimeData(domain: DateTime(2025, 1, 10), measure: 6),
      TimeData(domain: DateTime(2025, 1, 11), measure: 1),
      TimeData(domain: DateTime(2025, 1, 12), measure: 8),
    ];

    return SizedBox(
      height: 200,
      child: DChartBarT(
        fillColor: (group, timeData, index) {
          String day = DateFormat.E('ko').format(timeData.domain).substring(0, 1);
          return Theme.of(context).extension<CustomColors>()?.primary;
        },
        configRenderBar: ConfigRenderBar(
          barGroupInnerPaddingPx: 10,
          radius: 12,  // 막대 모서리 라운드 처리
        ),
        domainAxis: DomainAxis(
          showLine: true,
          tickLength: 0,
          gapAxisToLabel: 12,
          labelStyle: LabelStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tickLabelFormatterT: (domain) {
            return DateFormat.E('ko').format(domain).substring(0, 1);
          },
        ),
        measureAxis: const MeasureAxis(
          showLine: true,
        ),
        groupList: [
          TimeGroup(
            id: '1',
            data: series1.map((e) => TimeData(
              domain: e.domain,
              measure: e.measure, // 0~1 사이 값 -> 0~10으로 변환
            )).toList(),
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

/// 배지 리스트를 표시하는 위젯
class BadgeRow extends StatelessWidget {
  const BadgeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Row(
      children: [
        BadgeBox(
          label: '첫학습',
          isUnlocked: true, // 획득한 배지
        ),
        const SizedBox(width: 16),
        BadgeBox(
          label: '7일 연속',
          isUnlocked: true, // 획득한 배지
        ),
        const SizedBox(width: 16),
        BadgeBox(
          label: '미획득',
          isUnlocked: false, // 미획득 배지
        ),
      ],
    );
  }
}

/// 배지 박스 위젯
class BadgeBox extends StatelessWidget {
  final String label;
  final bool isUnlocked;

  const BadgeBox({
    required this.label,
    required this.isUnlocked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      children: [
        Container(
          width: 94,
          height: 62,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnlocked ? (customColors.primary ?? Colors.indigoAccent) : (customColors.neutral80 ?? Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.check : Icons.lock,
              color: isUnlocked ? (customColors.neutral100 ?? Colors.white) : (customColors.neutral30 ?? Colors.black26)
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: pretendardRegular(context).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

/// 사용자 통계 박스 위젯
class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({
    required this.value,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: pretendardSemiBold(context).copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: pretendardRegular(context).copyWith(fontSize: 12)),
      ],
    );
  }
}

/// 정보 카드 위젯
class InfoCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? leadingIcon;
  final Widget? child;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const InfoCard({
    required this.title,
    this.description,
    this.leadingIcon,
    this.child,
    this.trailingIcon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 24, color: Colors.black),
                      const SizedBox(width: 12),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: pretendardSemiBold(context).copyWith(fontSize: 18),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: pretendardRegular(context).copyWith(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (trailingIcon != null)
                  Icon(trailingIcon, size: 20, color: Colors.black54),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 16), // child와 상단 텍스트 간격
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
