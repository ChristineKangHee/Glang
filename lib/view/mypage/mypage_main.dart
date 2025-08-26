/// File: mypage_main.dart
/// Purpose: 마이페이지 화면 구현 (L10N 적용, 비활성화 로직 안정화)
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-08-26 by ChatGPT (L10N)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import '../../theme/font.dart';
import '../../theme/theme.dart';
import '../../viewmodel/badge_provider.dart';
import '../../viewmodel/badge_service.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../viewmodel/user_photo_url_provider.dart';
import '../../viewmodel/user_service.dart';
import '../community/Ranking/ranking_component.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 마이페이지 메인 화면 위젯
/// - 상단 앱바, 하단 네비게이션 바, 컨텐츠
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
              title: 'learning_stats'.tr(),                   // ✅ 학습 통계
              description: 'learning_stats_desc'.tr(),
              trailingIcon: Icons.arrow_forward_ios,
              disabled: true, // 🔒 언어와 무관하게 안전하게 비활성화
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/statistics');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'badges'.tr(),                           // ✅ 뱃지
              child: const BadgeRow(),
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/badge');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.article_rounded,
              title: 'community_posts'.tr(),                  // ✅ 커뮤니티 작성글
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/mycommunitypost');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              title: 'note_title'.tr(),                       // ✅ 메모 (기존 키 재사용)
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/memo');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              title: 'interpretation_title'.tr(),             // ✅ 해석 (기존 키 재사용)
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/interpretation');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.book,
              title: 'learning_history'.tr(),                 // ✅ 학습 기록
              trailingIcon: Icons.arrow_forward_ios,
              disabled: true, // 🔒 비활성화
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

/// 사용자 프로필 섹션 (Firebase 사용자 프로필 사진 표시)
class UserProfileSection extends ConsumerWidget {
  final String name;
  const UserProfileSection({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final photoUrl = ref.watch(userPhotoUrlProvider);
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                width: 3,
                color: customColors.neutral90 ?? Colors.grey[300]!,
              ),
            ),
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover);
              },
            )
                : Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover),
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
                    'edit_profile'.tr(), // ✅ 내 정보 수정
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

// 상단 import 구문 아래에 provider 추가
final myRankingProvider = FutureProvider<int>((ref) async {
  final rankings = await getRankings();
  final userName = ref.watch(userNameProvider) ?? '';
  final index = rankings.indexWhere((user) => user['name'] == userName);
  return index == -1 ? 0 : index + 1;
});

/// 사용자 경험치, 코스, 랭킹 통계 표시 섹션
class UserStatsSection extends ConsumerWidget {
  const UserStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsyncValue = ref.watch(userXPProvider); // 경험치
    final courseAsyncValue = ref.watch(userCourseProvider); // 코스
    final rankingAsyncValue = ref.watch(myRankingProvider); // 내 랭킹
    final customColors = ref.watch(customColorsProvider);

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: xpAsyncValue.when(
              data: (xp) => StatBox(value: xp.toString(), label: 'xp_label'.tr()), // ✅ 경험치
              loading: () => StatBox(value: 'loading'.tr(), label: 'xp_label'.tr()),
              error: (_, __) => StatBox(value: 'error_short'.tr(), label: 'xp_label'.tr()),
            ),
          ),
          VerticalDivider(color: customColors.neutral80),
          Expanded(
            child: courseAsyncValue.when(
              data: (course) => StatBox(value: course, label: 'course_title'.tr()), // ✅ 코스
              loading: () => StatBox(value: 'loading'.tr(), label: 'course_title'.tr()),
              error: (_, __) => StatBox(value: 'error_short'.tr(), label: 'course_title'.tr()),
            ),
          ),
          VerticalDivider(color: customColors.neutral80),
          Expanded(
            child: rankingAsyncValue.when(
              data: (rank) => StatBox(
                value: 'rank_value_format'.tr(args: ['${rank}']), // ✅ "{}위"/"#{}"
                label: 'rank_label'.tr(),                         // ✅ 랭킹
              ),
              loading: () => StatBox(value: 'loading'.tr(), label: 'rank_label'.tr()),
              error: (_, __) => StatBox(value: 'error_short'.tr(), label: 'rank_label'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

/// 수정된 BadgeBox 위젯
class BadgeBox extends StatelessWidget {
  final String label;
  final bool isUnlocked;
  final String? imageUrl; // 배지 이미지 URL 추가

  const BadgeBox({
    required this.label,
    required this.isUnlocked,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.18,
          height: screenWidth * 0.18,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnlocked
                ? (customColors.neutral60 ?? Colors.indigoAccent)
                : (customColors.primary ?? Colors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: imageUrl != null
                ? Image.asset(
              imageUrl!,
              fit: BoxFit.contain,
            )
                : Icon(
              Icons.star,
              size: screenWidth * 0.10,
              color: isUnlocked
                  ? (customColors.neutral80 ?? Colors.white)
                  : (customColors.neutral100 ?? Colors.black26),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: body_small_semi(context),
        ),
      ],
    );
  }
}

class BadgeRow extends ConsumerWidget {
  const BadgeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);
    final earnedIdsAsync = ref.watch(userEarnedBadgeIdsProvider);

    return badgesAsync.when(
      data: (badges) {
        final displayBadges = badges.take(3).toList();

        // 유저 보유 뱃지 ID
        final earnedIds = earnedIdsAsync.when(
          data: (ids) => ids,
          loading: () => const <String>[],
          error: (_, __) => const <String>[],
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: displayBadges.map((badge) {
            final localizedName = badge.name.pick(context);
            final isUnlocked = earnedIds.contains(badge.id);

            return Flexible(
              child: BadgeBox(
                label: localizedName,       // ✅ 현지화된 이름
                isUnlocked: isUnlocked,     // ✅ 실제 보유 여부
                imageUrl: badge.imageUrl,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('badges_load_error'.tr())),
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
  final bool disabled; // ✅ 언어와 무관하게 제어

  const InfoCard({
    required this.title,
    this.description,
    this.leadingIcon,
    this.child,
    this.trailingIcon,
    this.onTap,
    this.disabled = false, // ✅ 기본값 false
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.black.withOpacity(0.05) : Colors.white,
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
                    color: isDisabled ? Colors.grey : Colors.black54,
                  ),
              ],
            ),
            if (child != null && !isDisabled) ...[
              const SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
