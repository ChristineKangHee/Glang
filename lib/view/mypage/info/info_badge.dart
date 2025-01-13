import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class InfoBadge extends ConsumerWidget {
  const InfoBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "배지",
      ),
      body: BadgeWidget(),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      width: double.infinity,
      height: 660, // 전체 컨테이너의 높이 고정
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '활동 배지',
                  style: heading_xsmall(context),
                ),
                const SizedBox(height: 4),
                Text(
                  '이 때까지 획득한 활동 뱃지들을 확인해보세요!',
                  style: body_small(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: GridView.builder(
                itemCount: _badges.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140, // 가로 크기 조절
                  mainAxisSpacing: 16, // 배지 간 세로 간격
                  crossAxisSpacing: 16, // 배지 간 가로 간격
                  childAspectRatio: 1.0, // 정사각형 비율
                ),
                itemBuilder: (context, index) {
                  final badge = _badges[index];
                  final isObtained = badge['obtained'] as bool;
                  final backgroundColor = isObtained ? customColors.primary : customColors.neutral60;
                  final starColor = isObtained ? customColors.accent : customColors.neutral80;

                  return Container(
                    height: 160, // 세로 길이 고정
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.star,
                              color: starColor,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'] as String,
                          textAlign: TextAlign.center,
                          style: body_small_semi(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _badges = [
    {'name': '일일 챌린지', 'obtained': true},
    {'name': '시작이 반이다', 'obtained': true},
    {'name': '좋아요 누르기', 'obtained': true},
    {'name': '중급 달성', 'obtained': false},
    {'name': '주간 챌린지', 'obtained': false},
    {'name': '댓글 달기', 'obtained': false},
    {'name': '고급 달성', 'obtained': false},
    {'name': '피드 올리기', 'obtained': false},
  ];
}
