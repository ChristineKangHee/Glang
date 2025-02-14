import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/community/Ranking/ranking_component.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class RankingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '랭킹'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildTopThree(context, customColors),
            buildPodium(context, customColors),
            buildRankingList(context, customColors),
          ],
        ),
      ),
    );
  }
}

