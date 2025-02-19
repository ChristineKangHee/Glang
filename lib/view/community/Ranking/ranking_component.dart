import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/theme.dart';
import '../../../viewmodel/user_photo_url_provider.dart';
import '../../../viewmodel/user_service.dart';

/// Firebase에서 totalXP 기준으로 랭킹을 가져오는 함수
Future<List<Map<String, dynamic>>> getRankings() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('users').get();
    List<Map<String, dynamic>> rankings = [];

    for (var doc in querySnapshot.docs) {
      var userData = doc.data();

      if (userData['totalXP'] == null || userData['totalXP'] < 0) {
        userData['totalXP'] = 0;
      }

      rankings.add({
        'id': doc.id,
        'name': userData['nickname'] ?? userData['email'] ?? 'Unknown',
        'experience': userData['totalXP'] ?? 0,
        // Firestore에 저장된 사진 URL (업데이트되었으면 Firebase Cloud Storage의 URL)
        'image': userData['photoURL'] ?? 'assets/images/default_avatar.png',
      });
    }

    rankings.sort((a, b) {
      if (a['experience'] == b['experience']) {
        return a['name'].compareTo(b['name']);
      }
      return b['experience'].compareTo(a['experience']);
    });

    return rankings;
  } catch (e) {
    print('랭킹 가져오기 오류: $e');
    rethrow;
  }
}


/// 랭킹 카드 (프로필 사진 포함)
Widget buildRankCard(Map<String, dynamic> user, double size, CustomColors customColors, BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final currentUser = FirebaseAuth.instance.currentUser;
      String imagePath;
      if (currentUser != null && user['id'] == currentUser.uid) {
        final providerImageUrl = ref.watch(userPhotoUrlProvider);
        imagePath = (providerImageUrl != null && providerImageUrl.isNotEmpty)
            ? providerImageUrl
            : 'assets/images/default_avatar.png';
      } else {
        imagePath = (user['image'] != null && user['image'].toString().isNotEmpty)
            ? user['image']
            : 'assets/images/default_avatar.png';
      }
      final bool isDefault = imagePath == 'assets/images/default_avatar.png';
      final ImageProvider backgroundImage = imagePath.startsWith('http')
          ? NetworkImage(imagePath)
          : AssetImage(imagePath);

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: size,
              backgroundImage: backgroundImage,
              backgroundColor: isDefault ? customColors.neutral90 : null,
            ),
            const SizedBox(height: 5),
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
    },
  );
}


/// 상위 3명의 랭킹 카드 (Podium 포함)
Widget buildTopThreeWithPodium(BuildContext context, CustomColors customColors) {
  double screenWidth = MediaQuery.of(context).size.width;

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData) {
        return const Text('랭킹 정보를 불러오는 데 실패했습니다.');
      }

      final rankings = snapshot.data!;

      double getAvatarSize(int rank) {
        switch (rank) {
          case 1:
            return screenWidth * 0.10;
          case 2:
            return screenWidth * 0.08;
          case 3:
            return screenWidth * 0.07;
          default:
            return screenWidth * 0.07;
        }
      }

      double getPodiumWidth() => screenWidth * 0.2;

      double getPodiumHeight(int rank) {
        switch (rank) {
          case 1:
            return 40;
          case 2:
            return 30;
          case 3:
            return 25;
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
            const SizedBox(height: 8),
            buildPodiumBlock(rank, getPodiumHeight(rank), getPodiumWidth(), context, customColors),
          ],
        );
      }

      Widget placeholderSet(int rank) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPodiumBlock(rank, getPodiumHeight(rank), getPodiumWidth(), context, customColors),
            const SizedBox(height: 8),
            CircleAvatar(
              radius: getAvatarSize(rank),
              backgroundColor: customColors.neutral80,
              child: const Text('N/A', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 5),
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
          const SizedBox(width: 4),
          firstSet,
          const SizedBox(width: 4),
          thirdSet,
        ],
      );
    },
  );
}

/// 단상 (Podium) 표시
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
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: podiumColor,
      borderRadius: const BorderRadius.only(
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

/// 상위 3명의 랭킹 카드 (네트워크 이미지를 사용하는 버전)
Widget buildTopThree(BuildContext context, CustomColors customColors) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData) {
        return const Text('랭킹 정보를 불러오는 데 실패했습니다.');
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
                child: const Text('N/A', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 5),
              Text('N/A', style: body_small_semi(context).copyWith(color: customColors.neutral30)),
              Text('0 xp', style: body_xxsmall(context).copyWith(color: customColors.neutral60)),
            ],
          ),
        );
      }

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
          firstCard,
          thirdCard,
        ],
      );
    },
  );
}

/// 4등 이후의 랭킹 리스트 (Firebase 연결)
Widget buildRankingList(BuildContext context, CustomColors customColors) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getRankings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('랭킹 정보를 불러오는 데 실패했습니다. 오류: ${snapshot.error}');
      }
      if (!snapshot.hasData || snapshot.data!.length <= 3) {
        return const SizedBox.shrink();
      }

      final rankings = snapshot.data!;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                const SizedBox(width: 20),
                // 현재 사용자의 경우 provider를 사용하도록 Consumer로 감쌈
                Consumer(
                  builder: (context, ref, child) {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    String imagePath;
                    if (currentUser != null && user['id'] == currentUser.uid) {
                      final providerImageUrl = ref.watch(userPhotoUrlProvider);
                      imagePath = (providerImageUrl != null && providerImageUrl.isNotEmpty)
                          ? providerImageUrl
                          : 'assets/images/default_avatar.png';
                    } else {
                      imagePath = (user['image'] != null && user['image'].toString().isNotEmpty)
                          ? user['image']
                          : 'assets/images/default_avatar.png';
                    }
                    final bool isDefault = imagePath == 'assets/images/default_avatar.png';
                    final ImageProvider imageProvider = imagePath.startsWith('http')
                        ? NetworkImage(imagePath)
                        : AssetImage(imagePath);
                    return CircleAvatar(
                      backgroundImage: imageProvider,
                      backgroundColor: isDefault ? customColors.neutral90 : null,
                    );
                  },
                ),
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
