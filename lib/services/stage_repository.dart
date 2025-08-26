// lib/services/stage_repository.dart
// CHANGED: /stage_master 를 1회 fetch 후 메모리 캐시. 필요시 ID 단건 조회 지원.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/stage_master.dart';
import 'firestore_paths.dart';

class StageRepository {
  StageRepository._();
  static final StageRepository instance = StageRepository._();

  final _db = FirebaseFirestore.instance;

  // 메모리 캐시
  final Map<String, StageMaster> _cacheById = {};
  bool _allPreloaded = false;

  Future<List<StageMaster>> getAllStagesOnce() async {
    if (_allPreloaded && _cacheById.isNotEmpty) {
      return _cacheById.values.toList(growable: false);
    }
    final snap = await _db.collection(FsPaths.stageMaster).get(const GetOptions(source: Source.serverAndCache));
    for (final doc in snap.docs) {
      try {
        final sm = StageMaster.fromDoc(doc);
        _cacheById[sm.id] = sm;
      } catch (e, st) {
        if (kDebugMode) {
          // 로깅만
          print('[StageRepository] parse error on ${doc.id}: $e\n$st');
        }
      }
    }
    _allPreloaded = true;
    return _cacheById.values.toList(growable: false);
  }

  Future<StageMaster?> getStageByIdOnce(String stageId) async {
    if (_cacheById.containsKey(stageId)) return _cacheById[stageId];
    final doc = await _db.collection(FsPaths.stageMaster).doc(stageId).get(const GetOptions(source: Source.serverAndCache));
    if (!doc.exists) return null;
    final sm = StageMaster.fromDoc(doc);
    _cacheById[stageId] = sm;
    return sm;
  }

  // (선택) 강제 새로고침
  Future<void> refreshAll() async {
    _allPreloaded = false;
    _cacheById.clear();
    await getAllStagesOnce();
  }
}
