import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../theme/theme.dart';

/// Firebase에서 totalXP 기준으로 랭킹을 가져오는 함수
Future<List<Map<String, dynamic>>> getRankings() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance; // Firestore 인스턴스 선언

    // 모든 사용자 데이터를 가져옵니다. (totalXP > 0 조건 제거)
    final querySnapshot = await firestore.collection('users').get();

    List<Map<String, dynamic>> rankings = [];

    for (var doc in querySnapshot.docs) {
      var userData = doc.data();

      // totalXP가 null이거나 0 미만이면 0으로 설정
      if (userData['totalXP'] == null || userData['totalXP'] < 0) {
        userData['totalXP'] = 0;
      }

      rankings.add({
        'id': doc.id,
        'name': userData['nickname'] ?? userData['email'] ?? 'Unknown',
        'experience': userData['totalXP'] ?? 0,
        'image': userData['profileImage'] ?? 'assets/images/default_avatar.png',
      });
    }

    // xp가 높은 순으로 정렬하고, xp가 같으면 이름(가나다 순)으로 정렬
    rankings.sort((a, b) {
      if (a['experience'] == b['experience']) {
        return a['name'].compareTo(b['name']);
      }
      return b['experience'].compareTo(a['experience']);
    });

    return rankings;
  } catch (e) {
    print('랭킹 가져오기 오류: $e'); // 오류 로그 출력
    rethrow; // 오류를 다시 던져서 FutureBuilder에서 처리하게 함
  }
}
Widget buildTopThreeWithPodium(BuildContext context, CustomColors customColors) {
  double screenWidth = MediaQuery.of(context).size.width;

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다.');
      }

      final rankings = snapshot.data!;

      double getAvatarSize(int rank) {
        switch (rank) {
          case 1:
            return screenWidth * 0.10; // 1등 (가장 큼)
          case 2:
            return screenWidth * 0.08; // 2등
          case 3:
            return screenWidth * 0.07; // 3등
          default:
            return screenWidth * 0.07;
        }
      }

      double getPodiumWidth() {
        return screenWidth * 0.2;
      }

      double getPodiumHeight(int rank) {
        switch (rank) {
          case 1:
            return 40; // 1등 podium
          case 2:
            return 30; // 2등 podium
          case 3:
            return 25; // 3등 podium
          default:
            return 25;
        }
      }

      Widget buildRankSet({
        required Map<String, dynamic> user,
        required int rank,
      }) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRankCard(user, getAvatarSize(rank), customColors, context),
            SizedBox(height: 8),
            buildPodiumBlock(rank, getPodiumHeight(rank), getPodiumWidth(), context, customColors),
          ],
        );
      }

      Widget placeholderSet(int rank) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPodiumBlock(rank, getPodiumHeight(rank), getPodiumWidth(), context, customColors),
            SizedBox(height: 8),
            CircleAvatar(
              radius: getAvatarSize(rank),
              backgroundColor: customColors.neutral80,
              child: Text('N/A', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 5),
            Text('N/A', style: body_small_semi(context).copyWith(color: customColors.neutral30)),
            Text('0 xp', style: body_xxsmall(context).copyWith(color: customColors.neutral60)),
          ],
        );
      }

      Widget firstSet = rankings.isNotEmpty ? buildRankSet(user: rankings[0], rank: 1) : placeholderSet(1);
      Widget secondSet = rankings.length >= 2 ? buildRankSet(user: rankings[1], rank: 2) : placeholderSet(2);
      Widget thirdSet = rankings.length >= 3 ? buildRankSet(user: rankings[2], rank: 3) : placeholderSet(3);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          secondSet,
          SizedBox(width: 4),
          firstSet,
          SizedBox(width: 4),
          thirdSet,
        ],
      );
    },
  );
}


/// 상위 3명의 랭킹 카드
Widget buildTopThree(BuildContext context, CustomColors customColors) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); // 로딩 중 표시
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다.');
      }

      final rankings = snapshot.data!;

      // 플레이스홀더 카드: 데이터가 없을 경우 "N/A"로 표시
      Widget placeholderCard(double size) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: size,
                backgroundColor: customColors.neutral80,
                child: Text('N/A', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 5),
              Text('N/A', style: body_small_semi(context).copyWith(color: customColors.neutral30)),
              Text('0 xp', style: body_xxsmall(context).copyWith(color: customColors.neutral60)),
            ],
          ),
        );
      }

      // 1등(가운데), 2등(왼쪽), 3등(오른쪽)
      Widget firstCard = rankings.isNotEmpty
          ? buildRankCard(rankings[0], 40, customColors, context)
          : placeholderCard(40);
      Widget secondCard = rankings.length >= 2
          ? buildRankCard(rankings[1], 30, customColors, context)
          : placeholderCard(30);
      Widget thirdCard = rankings.length >= 3
          ? buildRankCard(rankings[2], 25, customColors, context)
          : placeholderCard(25);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          secondCard,
          // SizedBox(width: 20),
          firstCard,
          // SizedBox(width: 20),
          thirdCard,
        ],
      );
    },
  );
}

/// 단상 (Podium) 표시
Widget buildPodium(BuildContext context, CustomColors customColors) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 3) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다.');
      }

      final rankings = snapshot.data!;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildPodiumBlock(2, 30, 90, context, customColors), // 2등 단상
          buildPodiumBlock(1, 40, 90, context, customColors), // 1등 단상
          buildPodiumBlock(3, 25, 90, context, customColors), // 3등 단상
        ],
      );
    },
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

/// 랭킹 카드 (프로필 사진 포함)
Widget buildRankCard(Map<String, dynamic> user, double size, CustomColors customColors, BuildContext context) {
  // user['image']가 null 또는 빈 문자열이면 default 이미지 사용
  final String imagePath = (user['image'] != null && user['image'].toString().isNotEmpty)
      ? user['image']
      : 'assets/images/default_avatar.png';
  final bool isDefault = imagePath == 'assets/images/default_avatar.png';

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        CircleAvatar(
          radius: size,
          // 여기에선 모두 AssetImage로 처리 (필요 시 네트워크 이미지 처리를 추가할 수 있음)
          backgroundImage: AssetImage(imagePath),
          backgroundColor: isDefault ? customColors.neutral90 : null,
        ),
        SizedBox(height: 5),
        Text(
          user['name'],
          style: body_small_semi(context).copyWith(color: customColors.neutral30),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),

        Text(
          '${user['experience']} xp',
          style: body_xxsmall(context).copyWith(color: customColors.neutral60),
        ),
      ],
    ),
  );
}


/// 4등 이후의 랭킹 리스트 (Firebase 연결)
Widget buildRankingList(BuildContext context, CustomColors customColors) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData || snapshot.data!.length <= 3) {
        return SizedBox.shrink(); // 아무것도 표시하지 않음
      }

      final rankings = snapshot.data!;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: rankings.length - 3,
        itemBuilder: (context, index) {
          final user = rankings[index + 3];
          final rank = index + 4;
          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$rank',
                  style: body_small_semi(context).copyWith(color: customColors.neutral30),
                ),
                SizedBox(width: 20),
                Builder(builder: (context) {
                  final String imagePath = (user['image'] != null && user['image'].toString().isNotEmpty)
                      ? user['image']
                      : 'assets/images/default_avatar.png';
                  final bool isDefault = imagePath == 'assets/images/default_avatar.png';
                  return CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                    backgroundColor: isDefault ? customColors.neutral90 : null,
                  );
                }),
              ],
            ),
            title: Text(
              user['name'],
              style: body_small_semi(context).copyWith(color: customColors.neutral30),
            ),
            subtitle: Text(
              '${user['experience']} xp',
              style: body_xxsmall(context).copyWith(color: customColors.neutral60),
            ),
          );
        },
      );
    },
  );
}

