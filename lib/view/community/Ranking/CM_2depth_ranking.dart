/// File: CM_2detph_ranking.dart
/// Purpose: 랭킹 페이지를 구성하는 화면
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/community/Ranking/ranking_component.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';

// RankingPage 위젯: 랭킹 페이지를 구성하는 화면
class RankingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // customColorsProvider를 사용해 사용자 정의 색상 값을 가져옴
    final customColors = ref.watch(customColorsProvider);

    // 페이지의 구조를 Scaffold로 구성, 커스텀 앱바와 랭킹 관련 위젯들을 포함
    return Scaffold(
      // 커스텀 앱바, 제목은 '랭킹'
      appBar: CustomAppBar_2depth_4(title: 'ranking.title'.tr()),

      // 본문은 SingleChildScrollView로 감싸서 스크롤 가능하게 설정
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상위 3위 랭킹을 보여주는 위젯
            buildTopThreeWithPodium(context, customColors),

            // 전체 랭킹 목록을 보여주는 위젯
            buildRankingList(context, customColors),
          ],
        ),
      ),
    );
  }
}
