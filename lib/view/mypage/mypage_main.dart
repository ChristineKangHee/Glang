/// File: mypage_main.dart
/// Purpose: 마이페이지 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-02-12 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../viewmodel/user_service.dart';
import '../widgets/DoubleBackToExitWrapper.dart';

/// 마이페이지 메인 화면 위젯
/// - 상단 앱바, 하단 네비게이션 바, 컨텐츠
/// 마이페이지 메인 화면 위젯
class MyPageMain extends ConsumerWidget {
  const MyPageMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final userName = ref.watch(userNameProvider) ?? 'null'; // 사용자 이름 상태 구독

    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: CustomAppBar_MyPage(),
        body: SafeArea(
          child: Container(
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
            child: MyPageContent(name: userName), // 실제 화면 컨텐츠에 이름 전달
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      ),
    );
  }
}

/// 마이페이지의 컨텐츠 본문
class MyPageContent extends StatelessWidget {
  final String name;
  const MyPageContent({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileSection(name: name), // 사용자 프로필 섹션에 이름 전달
            const SizedBox(height: 40),
            const UserStatsSection(), // 사용자 경험치, 코스, 랭킹 표시
            const SizedBox(height: 24),
            InfoCard(
              title: '학습 통계',
              description: '일주일에 활동한 학습을 확인하세요!',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/statistics');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: '획득한 배지',
              child: const BadgeRow(),
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/badge');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.article_rounded,
              title: '커뮤니티 작성글',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/mycommunitypost');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              title: '메모',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/saved');
              },
            ),
            const SizedBox(height: 16),
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
class UserProfileSection extends StatelessWidget {
  final String name;
  const UserProfileSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(width: 3, color: customColors.neutral90 ?? Colors.grey[300]!),
            ),
          ),
          child: ClipOval(
            child: SvgPicture.asset(
              'assets/images/character.svg',
              fit: BoxFit.fill, // Ensures the image fills the container without distortion
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: heading_small(context)),
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
class UserStatsSection extends ConsumerWidget {
  const UserStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsyncValue = ref.watch(userXPProvider); // Firestore에서 XP 가져오기
    final courseAsyncValue = ref.watch(userCourseProvider); // Firestore에서 currentCourse 가져오기

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: xpAsyncValue.when(
              data: (xp) => StatBox(value: xp.toString(), label: '경험치'),
              loading: () => const StatBox(value: '...', label: '경험치'), // 로딩 중
              error: (_, __) => const StatBox(value: '오류', label: '경험치'), // 오류 발생 시
            ),
          ),
          VerticalDivider(color: Theme.of(context).extension<CustomColors>()?.neutral80),
          Expanded(
            child: courseAsyncValue.when(
              data: (course) => StatBox(value: course, label: '코스'),
              loading: () => const StatBox(value: '...', label: '코스'),
              error: (_, __) => const StatBox(value: '오류', label: '코스'),
            ),
          ),
        ],
      ),
    );
  }
}


/// 학습 통계 그래프 위젯
/*
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

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/mypage/info/statistics');
      },
      child: AbsorbPointer( // 내부 그래프 터치 이벤트를 무시하고 InfoCard의 onTap 동작
        child: SizedBox(
          height: 200,
          child: DChartBarT(
            fillColor: (group, timeData, index) {
              String day = DateFormat.E('ko').format(timeData.domain).substring(0, 1);
              return Theme.of(context).extension<CustomColors>()?.primary;
            },
            configRenderBar: ConfigRenderBar(
              barGroupInnerPaddingPx: 10,
              radius: 12,
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
                  measure: e.measure,
                )).toList(),
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class BadgeRow extends StatelessWidget {
  const BadgeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Flexible(child: BadgeBox(label: '첫학습', isUnlocked: false)),
        Flexible(child: BadgeBox(label: '3일 연속 출석', isUnlocked: false)),
        Flexible(child: BadgeBox(label: '7일 연속 출석', isUnlocked: false)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.25, // 화면 너비의 25%로 조정
          height: screenWidth * 0.15, // 화면 너비의 15%로 조정
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnlocked ? (customColors.primary ?? Colors.indigoAccent) : (customColors.neutral80 ?? Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.check : Icons.lock,
              color: isUnlocked ? (customColors.neutral100 ?? Colors.white) : (customColors.neutral30 ?? Colors.black26),
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
    // '학습 통계' 카드 비활성화 여부 확인
    final bool isDisabled = title == '학습 통계' || title == '학습 기록';

    return InkWell(
      onTap: isDisabled ? null : onTap, // 비활성화 시 onTap 비활성화
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.black.withOpacity(0.05) : Colors.white, // 비활성화 시 색상 변경
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDisabled
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
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
                      Icon(
                        leadingIcon,
                        size: 24,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: pretendardSemiBold(context).copyWith(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: pretendardRegular(context).copyWith(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (trailingIcon != null)
                  Icon(
                    isDisabled ? Icons.lock : trailingIcon,
                    size: 20,
                    color: isDisabled ? Colors.grey : Colors.black54, // 비활성화 시 아이콘 색상 변경
                  ),
              ],
            ),
            if (child != null && !isDisabled) ...[
              const SizedBox(height: 16), // child와 상단 텍스트 간격
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
