import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/badge_data.dart';
final userEarnedBadgesProvider = StreamProvider<List<AppBadge>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final badgesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('badges');

  return badgesCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => AppBadge.fromFirestore(doc)).toList();
  });
});
