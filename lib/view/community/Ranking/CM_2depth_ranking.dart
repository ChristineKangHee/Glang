/// File: CM_2depth_ranking.dart
/// Purpose: 랭킹 페이지 화면
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-08-26 (L10N 적용, 파일명 오타 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:readventure/theme/font.dart';
import 'package:readventure/view/community/Ranking/ranking_component.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class RankingPage extends ConsumerWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: 'ranking_title'.tr()), // ✅ L10N
      backgroundColor: customColors.neutral90,
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildTopThreeWithPodium(context, customColors),
            buildRankingList(context, customColors),
          ],
        ),
      ),
    );
  }
}
