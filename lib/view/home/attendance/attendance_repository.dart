/// File: attendance_repository.dart
/// Purpose: Firebase Firestore에서 출석 데이터를 가져오는 기능을 제공하는 저장소 클래스
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_model.dart'; // AttendanceDay 및 AttendanceStatus 정의 파일

class AttendanceRepository {
  final FirebaseFirestore firestore;

  AttendanceRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// 특정 사용자에 대해 [start]부터 [end]까지의 출석 데이터를 가져오는 함수.
  Future<List<AttendanceDay>> fetchAttendanceForRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      // 'timestamp' 필드로부터 날짜를 복원하거나, 'date' 필드를 그대로 사용할 수 있음
      final timestamp = data['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      final statusString = data['status'] as String;
      final xp = data['xp'] as int;

      AttendanceStatus status;
      switch (statusString) {
        case 'completed':
          status = AttendanceStatus.completed;
          break;
        case 'missed':
          status = AttendanceStatus.missed;
          break;
        default:
          status = AttendanceStatus.upcoming;
      }
      return AttendanceDay(
        date: _formatDate(date), // 아래에서 수정할 형식 적용
        status: status,
        xp: xp,
      );
    }).toList();
  }

  /// 날짜를 원하는 형식(예: "yyyy-M-d")으로 포맷하는 함수
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

}
