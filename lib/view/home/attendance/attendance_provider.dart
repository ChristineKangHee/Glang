/// File: attendance_provider.dart
/// Purpose: 출석 데이터 관리를 위한 Riverpod Provider 정의
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_model.dart';
import 'attendance_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 오늘을 기준으로 전전날 ~ 모레 날짜 계산
List<DateTime> calculateFiveDays() {
  final today = DateTime.now();
  return List.generate(5, (index) => today.add(Duration(days: index - 2)));
}

/// attendance 데이터를 받아오는 FutureProvider
final attendanceProvider = FutureProvider<List<AttendanceDay>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("사용자가 로그인되어 있지 않습니다.");
  }

  final repository = AttendanceRepository();

  // 전전날부터 모레까지의 날짜 범위 계산
  final fiveDays = calculateFiveDays();
  final startDate = DateTime(fiveDays.first.year, fiveDays.first.month, fiveDays.first.day);
  final endDate = DateTime(fiveDays.last.year, fiveDays.last.month, fiveDays.last.day, 23, 59, 59);

  // Firebase에서 해당 범위의 데이터를 가져옴
  final fetchedData = await repository.fetchAttendanceForRange(
    userId: user.uid,
    start: startDate,
    end: endDate,
  );

  // 날짜별 데이터를 맵핑 (날짜 포맷이 AttendanceDay.date와 일치해야 함)
  final Map<String, AttendanceDay> fetchedMap = {
    for (var day in fetchedData) day.date: day
  };

  // 5일치 데이터를 순서대로 채워 넣기
  List<AttendanceDay> attendanceDays = [];
  for (final date in fiveDays) {
    // final key = "${date.month}/${date.day}";
    final key = "${date.year}-${date.month}-${date.day}"; // 변경: 연도도 포함
    if (fetchedMap.containsKey(key)) {
      attendanceDays.add(fetchedMap[key]!);
    } else {
      // 데이터가 없으면 기본 상태로 upcoming (또는 원하는 기본값)
      attendanceDays.add(
        AttendanceDay(
          date: key,
          status: date.isBefore(DateTime.now()) ? AttendanceStatus.missed : AttendanceStatus.upcoming,
          xp: 0,
        ),
      );
    }
  }
  return attendanceDays;
});
