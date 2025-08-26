// lib/viewmodel/badge_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자가 획득한 배지 ID 목록을 실시간 스트림으로 제공
final userEarnedBadgeIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(const <String>[]);
  final col = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('badges');

  return col.snapshots().map((snap) {
    return snap.docs
        .map((d) => (d.data()['badgeId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  });
});
