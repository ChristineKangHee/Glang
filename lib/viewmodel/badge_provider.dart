/// File: badge_provider.dart
/// Purpose: 배지 데이터를 스트리밍으로 제공하는 Provider
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/badge_data.dart'; // AppBadge가 정의된 파일
import 'package:firebase_auth/firebase_auth.dart';

/// 배지 데이터를 스트리밍으로 제공하는 Provider
final badgesProvider = StreamProvider<List<AppBadge>>((ref) {
  final badgesCollection = FirebaseFirestore.instance.collection('badges');

  // Firestore의 'badges' 컬렉션을 구독하여 실시간으로 배지 데이터를 가져옴
  return badgesCollection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => AppBadge.fromFirestore(doc)).toList());
});

/// 첫 출석 배지를 부여하는 함수
Future<void> awardFirstAttendanceBadge() async {
  final user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자 가져오기
  if (user == null) return; // 사용자가 없으면 함수 종료

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final attendanceSnapshot = await userDocRef.collection('attendance').get();

  // 사용자가 출석 기록이 있는지 확인
  if (attendanceSnapshot.docs.isNotEmpty) {
    final attendanceDoc = attendanceSnapshot.docs.first; // 첫 번째 출석 기록 가져오기

    // 첫 번째 출석이 'completed' 상태가 아니라면 배지 부여
    if (attendanceDoc['status'] == 'completed') {
      await userDocRef.collection('badges').add({
        'badgeId': 'first_step', // '첫 걸음' 배지 ID
        'earnedAt': Timestamp.now(), // 배지를 획득한 시간
      });

      // 사용자 문서의 'earnedBadges' 필드에 배지를 추가
      await userDocRef.update({
        'earnedBadges': FieldValue.arrayUnion(['first_step']), // 'first_step' 배지를 추가
      });
    }
  }
}
