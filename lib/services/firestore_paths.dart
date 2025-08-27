// lib/services/firestore_paths.dart
class FsPaths {
  static String stages = 'stages';
  static String stageMaster = 'stages';
  static String sectionMaster = 'section_master';

  static String user(String uid) => 'users/$uid';

  // ✅ 컬렉션 경로가 되도록 중간 도큐먼트에 "root" 사용 (예약어 아님)
  // 경로: users/{uid}/progress/root/sections  → (컬렉션 OK)
  static String userProgressSections(String uid) =>
      'users/$uid/progress/root/sections';
}
