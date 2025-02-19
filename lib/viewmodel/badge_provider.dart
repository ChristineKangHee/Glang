import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/badge_data.dart'; // AppBadge가 정의된 파일
import 'package:firebase_auth/firebase_auth.dart';

final badgesProvider = StreamProvider<List<AppBadge>>((ref) {
  final badgesCollection = FirebaseFirestore.instance.collection('badges');
  return badgesCollection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => AppBadge.fromFirestore(doc)).toList());
});

Future<void> awardFirstAttendanceBadge() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final attendanceSnapshot = await userDocRef.collection('attendance').get();

  // Check if the user has attended for the first time
  if (attendanceSnapshot.docs.isNotEmpty) {
    final attendanceDoc = attendanceSnapshot.docs.first; // Get the first attendance record

    // If the first attendance is not marked as completed, update the badge
    if (attendanceDoc['status'] != 'completed') {
      await userDocRef.collection('badges').add({
        'badgeId': 'first_step',
        'earnedAt': Timestamp.now(),
      });

      // Update the 'earnedBadges' field in the user's document
      await userDocRef.update({
        'earnedBadges': FieldValue.arrayUnion(['first_step']), // Add 'first_step' badge
      });
    }
  }
}
