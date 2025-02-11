import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/community/Ranking/ranking_data.dart';

import '../../../theme/theme.dart';

/// 상위 3명의 랭킹 카드
Widget buildTopThree(BuildContext context, CustomColors customColors) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      buildRankCard(rankings[1], 30, customColors, context), // 2등
      SizedBox(width: 20),
      buildRankCard(rankings[0], 40, customColors, context), // 1등 (가운데, 더 큼)
      SizedBox(width: 20),
      buildRankCard(rankings[2], 25, customColors, context), // 3등 (더 작게)
    ],
  );
}

/// 단상 (Podium) 표시
Widget buildPodium(BuildContext context, CustomColors customColors) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      buildPodiumBlock(2, 30, 90, context, customColors), // 2등 단상
      buildPodiumBlock(1, 40, 90, context, customColors), // 1등 단상
      buildPodiumBlock(3, 25, 90, context, customColors), // 3등 단상
    ],
  );
}

Widget buildPodiumBlock(int rank, double height, double width, BuildContext context, CustomColors customColors) {
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
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      '$rank',
      style: body_small_semi(context).copyWith(color: customColors.neutral100),
    ),
  );
}

/// 상위 3명의 카드 (프로필 사진 포함)
Widget buildRankCard(Map<String, dynamic> user, double size, CustomColors customColors, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        CircleAvatar(
          radius: size,
          backgroundImage: AssetImage(user['image']), // 프로필 이미지
        ),
        SizedBox(height: 5),
        Text(user['name'], style: body_small_semi(context).copyWith(color: customColors.neutral30)),
        Text('${user['experience']} xp', style: body_xxsmall(context).copyWith(color: customColors.neutral60)),
      ],
    ),
  );
}
