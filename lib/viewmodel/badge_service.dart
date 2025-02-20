import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/badge_data.dart';

// 사용자가 획득한 배지를 실시간으로 제공하는 StreamProvider
final userEarnedBadgesProvider = StreamProvider<List<AppBadge>>((ref) {
  // 현재 로그인된 사용자의 UID 가져오기
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // 사용자가 로그인되어 있지 않으면 빈 리스트 반환
  if (userId == null) return Stream.value([]);

  // Firestore에서 사용자의 배지 컬렉션 참조
  final badgesCollection = FirebaseFirestore.instance
      .collection('users') // 'users' 컬렉션에서
      .doc(userId) // 현재 사용자의 문서 가져오기
      .collection('badges'); // 해당 문서 안의 'badges' 서브 컬렉션 참조

  // 배지 컬렉션의 변경 사항을 감지하여 List<AppBadge> 형태로 변환하여 반환
  return badgesCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => AppBadge.fromFirestore(doc)).toList();
  });
});
