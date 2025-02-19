import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../util/box_shadow_styles.dart';
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
      body: SingleChildScrollView(
        child: BadgeWidget(),
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: customColors.neutral100,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double spacing = 16;
                final double badgeSize = (constraints.maxWidth - spacing * 2) / 3;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: _badges.map((badge) {
                    final isObtained = badge['obtained'] as bool;
                    final backgroundColor = isObtained ? customColors.primary : customColors.neutral60;
                    final starColor = isObtained ? customColors.secondary : customColors.neutral80;
                    final description = isObtained
                        ? badge['description']
                        : '이 배지를 얻으려면\n${badge['howToEarn']}을 시도해 보세요!';

                    return GestureDetector(
                      onTap: () => _showBadgePopup(context, badge, description, customColors),
                      child: SizedBox(
                        width: badgeSize,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: badgeSize * 0.6,
                              height: badgeSize * 0.6,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: badge['imageUrl'] != null
                                    ? Image.asset(
                                  badge['imageUrl'],
                                  fit: BoxFit.cover,
                                )
                                    : Icon(
                                  Icons.star, // 아이콘을 원하는 다른 것으로 변경 가능
                                  color: starColor,
                                  size: badgeSize * 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IntrinsicWidth(
                              child: Text(
                                badge['name'] as String,
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
          ),
        ],
      ),
    );
  }

  void _showBadgePopup(BuildContext context, Map<String, dynamic> badge, String description, CustomColors customColors) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isObtained = badge['obtained'] as bool;
        final Color backgroundColor = isObtained ? customColors.primary! : customColors.neutral60!;
        final Color starColor = isObtained ? customColors.secondary! : customColors.neutral80!;

        return AlertDialog(
          title: Text(
            badge['name'] as String,
            style: body_medium_semi(context),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: badge['imageUrl'] != null
                      ? Image.asset(
                    badge['imageUrl'],
                    fit: BoxFit.cover,
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
                function: () {
                  Navigator.of(context).pop();
                },
                title: '확인',
              ),
            ),
          ],
        );
      },
    );
  }


  final List<Map<String, dynamic>> _badges = [
    {
      'name': '첫걸음',
      'obtained': false,
      'description': '글랑에 오신 걸 환영합니다! 첫 발걸음을 내디뎠어요.',
      'howToEarn': '앱에 첫 로그인',
      'imageUrl': 'assets/images/first_badge.png', // 이미지 경로 지정
    },
    {
      'name': '3일 연속 출석',
      'obtained': false,
      'description': '꾸준한 학습 습관이 시작되었어요!',
      'howToEarn': '3일 연속 출석하기',
    },
    {'name': '7일 연속 출석', 'obtained': false, 'description': '일주일 동안 쉬지 않고 학습을 이어갔어요! 앞으로도 계속 도전해 보세요.', 'howToEarn': '7일 연속 출석하기', 'imageUrl': 'assets/images/seven_day_badge.png',},
    {'name': '요약 마스터', 'obtained': false, 'description': '핵심을 짚어내는 능력이 뛰어나군요! 요약 실력이 날로 성장하고 있어요.', 'howToEarn': '요약 미션 완수하기'},
    {'name': '비판적 사고가', 'obtained': false, 'description': '깊이 있는 질문을 던지는 능력이 돋보이네요!', 'howToEarn': '챗봇에게 질문하기'},
    {'name': '핵심찾기 고수', 'obtained': false, 'description': '텍스트 속에서 중요한 부분을 정확히 찾아내는 능력이 뛰나요!', 'howToEarn': '다지선다 미션 완수하기'},
    {'name': '창의적 사고가', 'obtained': false, 'description': '남다른 시각으로 세상을 바라보는 능력을 키워가고 있어요!', 'howToEarn': '결말 바꾸기 미션 완수하기'},
    {'name': '첫 글 작성', 'obtained': false, 'description': '처음으로 자신의 생각을 글로 표현했어요. 앞으로 더 많은 이야기를 들려주세요!', 'howToEarn': '첫 번째 글 작성'},
    {'name': '소통왕', 'obtained': false, 'description': '다른 사람과 활발하게 소통하며 생각을 나누고 있어요!', 'howToEarn': '토론 미션 완수하기'},
    {'name': '글 공유 챔피언', 'obtained': false, 'description': '좋은 글은 함께 나눠야 하죠! 여러분의 공유가 더 많은 배움을 만듭니다.', 'howToEarn': '에세이 글 올리기'},
    {'name': '월간 챌린지', 'obtained': false, 'description': '이달의 목표를 달성했어요! 꾸준한 도전을 응원합니다.', 'howToEarn': '월간 목표 완료'},
    {'name': '좋아요 스타', 'obtained': false, 'description': '사람들의 공감을 얻는 멋진 글을 작성하고 있어요!', 'howToEarn': '좋아요를 많이 받은 글 작성'},
  ];
}
