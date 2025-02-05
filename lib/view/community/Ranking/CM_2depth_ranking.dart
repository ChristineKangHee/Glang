import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/community/Ranking/ranking_component.dart';
import 'package:readventure/view/community/Ranking/ranking_data.dart';
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
            _buildRankingList(customColors),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumBlock(int rank, double height, double width, BuildContext context, CustomColors customColors) {
    Color podiumColor;
    switch (rank) {
      case 1:
        podiumColor = customColors.primary!;
        break;
      case 2:
        podiumColor = customColors.primary60!;
        break;
      case 3:
        podiumColor = customColors.primary40!;
        break;
      default:
        podiumColor = customColors.primary!;
    }

    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: podiumColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: body_small_semi(context).copyWith(color: customColors.neutral100),
      ),
    );
  }

  /// 4등 이후의 랭킹 리스트
  Widget _buildRankingList(CustomColors customColors) {
    return ListView.builder(
      shrinkWrap: true, // 내부에서 크기 조절 가능하도록 설정
      physics: NeverScrollableScrollPhysics(), // 내부 스크롤 방지
      itemCount: rankings.length - 3,
      itemBuilder: (context, index) {
        final user = rankings[index + 3];
        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user['rank']}', // 등수
                style: body_small_semi(context).copyWith(color: customColors.neutral30,),
              ),
              SizedBox(width: 20),
              CircleAvatar(
                backgroundImage: AssetImage(user['image']), // 프로필 이미지
              ),
            ],
          ),
          title: Text(user['name'], style: body_small_semi(context).copyWith(color: customColors.neutral30,)),
          subtitle: Text('${user['experience']} xp', style: body_xxsmall(context).copyWith(color: customColors.neutral60,)),
        );
      },
    );
  }
}
