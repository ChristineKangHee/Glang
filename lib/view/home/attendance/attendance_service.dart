/// File: attendance_service.dart
/// Purpose: 사용자의 출석 상태를 Firestore에 등록 및 업데이트하는 서비스 함수 제공
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

import 'package:cloud_firestore/cloud_firestore.dart';

/// 오늘 날짜에 해당하는 출석 기록을 Firestore에 등록/업데이트하는 함수
Future<void> markTodayAttendanceAsChecked(String userId) async {
  final now = DateTime.now().toUtc();
  final dateStr = "${now.year}-${now.month}-${now.day}";

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final attendanceRef = userRef.collection('attendance').doc(dateStr);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final userDoc = await transaction.get(userRef);
    final attendanceDoc = await transaction.get(attendanceRef);

    int currentXP = userDoc.exists ? (userDoc.data()?['totalXP'] ?? 0) : 0;

    if (!attendanceDoc.exists) {
      // 출석 체크 신규 등록
      transaction.set(attendanceRef, {
        'date': dateStr,
        'timestamp': Timestamp.fromDate(now),
        'status': 'completed',
        'xp': 10,
      });

      // XP 증가
      transaction.update(userRef, {'totalXP': currentXP + 10});
    } else {
      final data = attendanceDoc.data();
      if (data != null && data['status'] != 'completed') {
        // 기존 출석 체크를 완료 상태로 변경
        transaction.update(attendanceRef, {'status': 'completed'});

        // XP 증가
        transaction.update(userRef, {'totalXP': currentXP + 10});
      }
    }
  });
}
