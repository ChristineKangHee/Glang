import '../model/section_data.dart';

/// 섹션 ID/인덱스 관련 유틸 – 한 곳에서만 관리!
class SectionIds {
  /// 규칙 기반 섹션 ID: "section{index}"
  static String fromIndex(int index) => 'section$index';

  /// stage_001 → 1, stage_012 → 12
  static int stageIndex(String stageId) {
    final numStr = RegExp(r'\d+').firstMatch(stageId)?.group(0) ?? '0';
    return int.tryParse(numStr) ?? 0;
  }

  /// 4개씩 묶는 규칙: 001~004=1, 005~008=2, ...
  static int sectionIndexFromStageRuleOf4(String stageId) {
    final n = stageIndex(stageId);
    if (n <= 0) return 0;
    return ((n - 1) ~/ 4) + 1;
  }

  /// 규칙으로 계산한 섹션 ID
  static String sectionIdFromStageRuleOf4(String stageId) {
    final idx = sectionIndexFromStageRuleOf4(stageId);
    return fromIndex(idx);
  }
}

/// (편의) SectionData에 바로 섹션 ID 얻기
extension SectionDataX on SectionData {
  String get sectionId => SectionIds.fromIndex(section);
}
