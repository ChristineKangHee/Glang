/// File: info_badge.dart
/// Purpose: 뱃지 리스트 구성화면
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../viewmodel/theme_controller.dart';
import '../../../model/badge_data.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../util/box_shadow_styles.dart';
import '../../../viewmodel/badge_provider.dart';
import '../../../viewmodel/badge_service.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';

class InfoBadge extends ConsumerWidget {
  const InfoBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: "배지"),
      backgroundColor: customColors.neutral90,
      body: const SingleChildScrollView(
        child: BadgeWidget(),
      ),
    );
  }
}

class BadgeWidget extends ConsumerWidget {
  const BadgeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final badgesAsync = ref.watch(badgesProvider);
    final earnedBadgesAsync = ref.watch(userEarnedBadgesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('활동 배지', style: heading_xsmall(context)),
          const SizedBox(height: 4),
          Text('이 때까지 획득한 활동 배지를 확인해보세요!', style: body_small(context)),
          const SizedBox(height: 20),
          badgesAsync.when(
            data: (badges) {
              // 사용자가 획득한 배지 리스트 가져오기
              final earnedBadges = earnedBadgesAsync.when(
                data: (data) => data,
                loading: () => <String>[],
                error: (_, __) => <String>[],
              );

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: customColors.neutral100,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double spacing = 16;
                    final double badgeSize = (constraints.maxWidth - spacing * 2) / 3;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: badges.map((AppBadge badge) {
                        final isObtained = earnedBadges.contains(badge.id);
                        final backgroundColor = isObtained
                            ? customColors.primary
                            : customColors.neutral60;
                        final starColor = isObtained
                            ? customColors.secondary
                            : customColors.neutral80;
                        final description = isObtained
                            ? badge.description
                            : '이 배지를 얻으려면\n${badge.howToEarn}를 시도해 보세요!';

                        return GestureDetector(
                          onTap: () => _showBadgePopup(
                              context, badge, isObtained, description, customColors),
                          child: SizedBox(
                            width: badgeSize,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 배지 아이콘 표시
                                Container(
                                  width: badgeSize * 0.6,
                                  height: badgeSize * 0.6,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: badge.imageUrl != null
                                        ? Opacity(
                                      opacity: isObtained ? 1.0 : 0.3,
                                      child: Image.asset(
                                        badge.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Icon(
                                      Icons.star,
                                      color: starColor,
                                      size: badgeSize * 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicWidth(
                                  child: Text(
                                    badge.name,
                                    textAlign: TextAlign.center,
                                    style: body_small_semi(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('오류: $err')),
          ),
        ],
      ),
    );
  }

  /// 배지 팝업을 표시하는 함수
  void _showBadgePopup(
      BuildContext context, AppBadge badge, bool isObtained, String description, CustomColors customColors) {
    showDialog(
      context: context,
      builder: (context) {
        final Color backgroundColor = isObtained ? customColors.primary! : customColors.neutral60!;
        final Color starColor = isObtained ? customColors.secondary! : customColors.neutral80!;
        return AlertDialog(
          title: Text(
            badge.name,
            style: body_medium_semi(context),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 배지 이미지 또는 아이콘 표시
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: badge.imageUrl != null
                      ? Opacity(
                    opacity: isObtained ? 1.0 : 0.3,
                    child: Image.asset(
                      badge.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.star,
                    color: starColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: body_small(context).copyWith(color: customColors.neutral30),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Align(
              alignment: Alignment.center,
              child: ButtonPrimary_noPadding(
                function: () => Navigator.of(context).pop(),
                title: '확인',
              ),
            ),
          ],
        );
      },
    );
  }
}
