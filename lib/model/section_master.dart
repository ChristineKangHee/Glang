// lib/model/section_master.dart
// CHANGED: title/detail → LocalizedText 로 변환. stageIds는 그대로 유지.
// - fromDoc/toMap에서 ko/en 스키마 매핑
// - 구 스키마(단일 문자열) 안전 폴백

import 'package:cloud_firestore/cloud_firestore.dart';
import 'localized_types.dart';

class SectionMaster {
  final String id;                     // 문서 ID (stageId와 동일한 관리 규칙)
  final LocalizedText title;           // CHANGED
  final LocalizedText detail;          // CHANGED
  final List<String> stageIds;

  SectionMaster({
    required this.id,
    this.title = const LocalizedText(),
    this.detail = const LocalizedText(),
    this.stageIds = const [],
  });

  factory SectionMaster.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});
    final dynTitle = data['title'];
    final dynDetail = data['detail'];
    return SectionMaster(
      id: doc.id,
      title: (dynTitle is Map<String, dynamic> || dynTitle is String)
          ? LocalizedText.fromJson(dynTitle as dynamic)
          : const LocalizedText(),
      detail: (dynDetail is Map<String, dynamic> || dynDetail is String)
          ? LocalizedText.fromJson(dynDetail as dynamic)
          : const LocalizedText(),
      stageIds: List<String>.from(data['stageIds'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title.toJson(),
    'detail': detail.toJson(),
    'stageIds': stageIds,
  };
}
