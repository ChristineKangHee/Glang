// lib/model/section_data.dart
// CHANGED: SectionData만 유지(표시 텍스트 다국어). StageData는 stage_data.dart에서 import해서 사용.

import 'package:flutter/foundation.dart';
import 'localized_types.dart';
import 'stage_data.dart'; // StageData를 여기서 사용

@immutable
class SectionData {
  final int section;                 // 또는 섹션 ID를 숫자로 맵핑
  final LocalizedText title;         // CHANGED
  final LocalizedText sectionDetail; // CHANGED
  final List<StageData> stages;

  const SectionData({
    required this.section,
    this.title = const LocalizedText(),
    this.sectionDetail = const LocalizedText(),
    this.stages = const [],
  });

  SectionData copyWith({
    int? section,
    LocalizedText? title,
    LocalizedText? sectionDetail,
    List<StageData>? stages,
  }) {
    return SectionData(
      section: section ?? this.section,
      title: title ?? this.title,
      sectionDetail: sectionDetail ?? this.sectionDetail,
      stages: stages ?? this.stages,
    );
  }
}
