// lib/viewmodel/badge_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/badge_data.dart'; // AppBadge + L10N 포함

/// 모든 배지 메타를 스트리밍으로 제공
final badgesProvider = StreamProvider<List<AppBadge>>((ref) {
  final badgesCollection = FirebaseFirestore.instance.collection('badges');
  return badgesCollection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => AppBadge.fromFirestore(doc)).toList());
});

/// 첫 출석 배지 부여(중복 방지 포함)
Future<void> awardFirstAttendanceBadge() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final attendanceSnapshot =
  await userDoc.collection('attendance').limit(1).get();

  // 출석 기록이 있고 상태가 completed인 경우에만 부여
  if (attendanceSnapshot.docs.isNotEmpty &&
      (attendanceSnapshot.docs.first.data()['status'] == 'completed')) {
    const badgeId = 'first_step';

    // 이미 user.badges에 존재하는지 확인
    final userBadgesCol = userDoc.collection('badges');
    final exists =
    await userBadgesCol.where('badgeId', isEqualTo: badgeId).limit(1).get();
    if (exists.docs.isNotEmpty) return; // 이미 부여됨

    // 부여
    await userBadgesCol.add({
      'badgeId': badgeId,
      'earnedAt': Timestamp.now(),
    });

    // users 문서의 earnedBadges 배열에도 반영(중복 방지)
    await userDoc.update({
      'earnedBadges': FieldValue.arrayUnion([badgeId]),
    });
  }
}
