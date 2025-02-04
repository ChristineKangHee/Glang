/// File: attendance_model.dart
/// Purpose: 출석 데이터 모델을 정의하고, 출석 상태 변환 함수 제공
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

/// 출석 상태를 나타내는 열거형(enum)
enum AttendanceStatus { missed, completed, upcoming }

/// 문자열을 [AttendanceStatus]로 변환하는 함수
AttendanceStatus attendanceStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return AttendanceStatus.completed;
    case 'missed':
      return AttendanceStatus.missed;
    default:
      return AttendanceStatus.upcoming;
  }
}

/// [AttendanceStatus]를 문자열로 변환하는 함수
String attendanceStatusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.completed:
      return 'completed';
    case AttendanceStatus.missed:
      return 'missed';
    case AttendanceStatus.upcoming:
      return 'upcoming';
  }
}

/// 출석 데이터를 담는 모델 클래스
class AttendanceDay {
  /// 날짜를 'M/d' 형태의 문자열로 저장 (예: "1/21")
  final String date;

  /// 출석 상태
  final AttendanceStatus status;

  /// 해당 날짜에 획득한 XP
  final int xp;

  AttendanceDay({
    required this.date,
    required this.status,
    required this.xp,
  });

  /// Map 데이터를 모델로 변환하는 팩토리 생성자
  factory AttendanceDay.fromMap(Map<String, dynamic> map) {
    // map에서 date 필드는 Timestamp나 문자열일 수 있으므로 상황에 맞게 처리 필요
    // 여기서는 문자열 형태라고 가정
    return AttendanceDay(
      date: map['date'] as String? ?? '',
      status: attendanceStatusFromString(map['status'] as String? ?? 'upcoming'),
      xp: (map['xp'] as num?)?.toInt() ?? 0,
    );
  }

  /// 모델 데이터를 Map 형태로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'status': attendanceStatusToString(status),
      'xp': xp,
    };
  }
}
