// // lib/services/section_repository.dart
// // CHANGED: /section_master 는 1회 fetch + 캐시.
// //          향후 사용자 맞춤 섹션은 /users/{uid}/sections/{sectionId} 로 스테이지 조합을 읽어올 수 있도록 API 포함.
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import '../model/section_master.dart';
// import 'firestore_paths.dart';
//
// class SectionRepository {
//   SectionRepository._();
//   static final SectionRepository instance = SectionRepository._();
//
//   final _db = FirebaseFirestore.instance;
//
//   final Map<String, SectionMaster> _cacheById = {};
//   bool _allPreloaded = false;
//
//   Future<List<SectionMaster>> getAllSectionsOnce() async {
//     if (_allPreloaded && _cacheById.isNotEmpty) {
//       return _cacheById.values.toList(growable: false);
//     }
//     final snap = await _db.collection(FsPaths.sectionMaster).get(const GetOptions(source: Source.serverAndCache));
//     for (final doc in snap.docs) {
//       try {
//         final sm = SectionMaster.fromDoc(doc);
//         _cacheById[sm.id] = sm;
//       } catch (e, st) {
//         if (kDebugMode) {
//           print('[SectionRepository] parse error on ${doc.id}: $e\n$st');
//         }
//       }
//     }
//     _allPreloaded = true;
//     return _cacheById.values.toList(growable: false);
//   }
//
//   Future<SectionMaster?> getSectionByIdOnce(String sectionId) async {
//     if (_cacheById.containsKey(sectionId)) return _cacheById[sectionId];
//     final doc = await _db.collection(FsPaths.sectionMaster).doc(sectionId).get(const GetOptions(source: Source.serverAndCache));
//     if (!doc.exists) return null;
//     final sm = SectionMaster.fromDoc(doc);
//     _cacheById[sectionId] = sm;
//     return sm;
//   }
//
//   // --- 향후 개인화 섹션 조합용 API ---
//
//   /// 사용자별 섹션 정의: /users/{uid}/sections/{sectionId}
//   /// 필드 예시: { stageIds: [ "stage_001", "stage_002", ... ] }
//   Future<List<String>> getUserSectionStageIdsOnce({
//     required String uid,
//     required String sectionId,
//   }) async {
//     final doc = await _db.collection(FsPaths.userSections(uid)).doc(sectionId).get(const GetOptions(source: Source.serverAndCache));
//     if (!doc.exists) return const [];
//     final data = (doc.data() as Map<String, dynamic>? ?? {});
//     return List<String>.from(data['stageIds'] ?? const []);
//   }
//
//   Future<void> setUserSectionStageIds({
//     required String uid,
//     required String sectionId,
//     required List<String> stageIds,
//   }) async {
//     await _db.collection(FsPaths.userSections(uid)).doc(sectionId).set({
//       'stageIds': stageIds,
//       // 추가 메타 필요시 여기에
//     }, SetOptions(merge: true));
//   }
//
//   Future<void> refreshAll() async {
//     _allPreloaded = false;
//     _cacheById.clear();
//     await getAllSectionsOnce();
//   }
// }
