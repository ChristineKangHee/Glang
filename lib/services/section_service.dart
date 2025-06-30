// lib/services/section_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/section_master.dart';

class SectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _sections = FirebaseFirestore.instance.collection('sections');

  /// 새 섹션 생성 후, 생성된 문서 ID 반환
  Future<String> createSection({
    required String title,
    required String detail,
    required List<String> stageIds,
  }) async {
    final docRef = await _sections.add({
      'title': title,
      'detail': detail,
      'stageIds': stageIds,
    });
    return docRef.id;
  }

  /// 섹션 단건 조회
  Future<SectionMaster?> getSection(String sectionId) async {
    final doc = await _sections.doc(sectionId).get();
    if (!doc.exists) return null;
    return SectionMaster.fromDoc(doc);
  }

  /// 모든 섹션 불러오기
  Future<List<SectionMaster>> getAllSections() async {
    final snap = await _sections.get();
    return snap.docs.map((d) => SectionMaster.fromDoc(d)).toList();
  }

  /// title/detail/stageIds 중 필요한 것만 업데이트
  Future<void> updateSection({
    required String sectionId,
    String? title,
    String? detail,
    List<String>? stageIds,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (detail != null) data['detail'] = detail;
    if (stageIds != null) data['stageIds'] = stageIds;
    await _sections.doc(sectionId).update(data);
  }

  /// 섹션 삭제
  Future<void> deleteSection(String sectionId) async {
    await _sections.doc(sectionId).delete();
  }
}
