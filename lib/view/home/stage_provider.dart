// lib/view/home/stage_provider.dart
// CHANGED: 섹션 마스터 의존 제거.
//          진행 경로: users/{uid}/progress/root/sections/{stageId}
//          StageMaster의 difficultyLevel/textContents 필드 사용.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_paths.dart'; // ⬅️ 추가
import 'package:flutter/foundation.dart'; // debugPrint, kDebugMode
import '../../model/section_data.dart';
import '../../model/stage_data.dart';               // StageData, StageStatus
import '../../model/stage_master.dart';            // StageMaster
// import '../../model/localized_types.dart';       // ← 더 이상 직접 사용 안 함이면 제거
import '../../services/stage_repository.dart';
// import '../../services/section_repository.dart'; // ← 제거
import '../../services/learning_assembly_service.dart';

// --- User id state ---
final userIdProvider = StateProvider<String?>((ref) => null);

// --- 1) stagesProvider: 사용자용 "모든 스테이지" (공용 섹션 조립 + 진행 오버레이 1회) ---
final stagesProvider = FutureProvider<List<StageData>>((ref) async {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return [];

  // 1) (캐시 목적) 스테이지 마스터만 로딩
  await StageRepository.instance.getAllStagesOnce();
  final sections = await LearningAssemblyService.instance.buildPublicSections();

  // 2) 섹션→스테이지 평탄화
  final allStages = sections.expand((s) => s.stages).toList(growable: false);
  if (allStages.isEmpty) return const [];

  // 3) 진행(progress) 일괄 로딩 (✅ 새 경로)
  final path = FsPaths.userProgressSections(uid);
  _debugCheckCollectionPath(path, tag: 'stagesProvider'); // ⬅️ 여기

  final progressSnap = await FirebaseFirestore.instance
      .collection(path)
      .get(const GetOptions(source: Source.serverAndCache));



  final progressById = {
    for (final d in progressSnap.docs) d.id: d.data(),
  };

  // 4) 진행 오버레이 (activityCompleted 맵 우선 + 최상위 폴백)
  final merged = allStages.map((st) {
    final p = progressById[st.stageId];
    if (p == null) return st;

    final ac = _acFromProgress(p);
    final statusStr = (p['status'] ?? 'locked').toString();
    final status = _statusFromString(statusStr);
    final achievement = (p['achievement'] is int)
        ? p['achievement'] as int
        : int.tryParse((p['achievement'] ?? '0').toString()) ?? 0;

    return st.copyWith(
      activityCompleted: ac,
      status: status,
      achievement: achievement,
    );
  }).toList(growable: false);

  return merged;
});

// --- 2) 현재 선택한 스테이지 id ---
final selectedStageIdProvider = StateProvider<String?>((ref) => null);

// --- 3) currentStageProvider: 선택된 id에 해당하는 StageData ---
final currentStageProvider = Provider<StageData?>((ref) {
  final stageId = ref.watch(selectedStageIdProvider);
  final stagesAsync = ref.watch(stagesProvider);
  if (stageId == null || stagesAsync.isLoading) return null;

  final allStages = stagesAsync.value ?? const <StageData>[];
  return allStages.firstWhereOrNull((stage) => stage.stageId == stageId);
});

// --- 4) stagesStreamProvider: 진행(progress) 실시간 구독 + 마스터 조인 ---
final stagesStreamProvider = StreamProvider<List<StageData>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return Stream.value(const <StageData>[]);
  }

  // ✅ 새 경로로 스트림 구독
  final path = FsPaths.userProgressSections(uid);
  _debugCheckCollectionPath(path, tag: 'stagesStreamProvider'); // ⬅️ 여기

  final progressStream = FirebaseFirestore.instance
      .collection(path)
      .snapshots();


  return progressStream.asyncMap((snapshot) async {
    // 마스터 캐시 준비
    final masters = await StageRepository.instance.getAllStagesOnce();
    final byId = {for (final m in masters) m.id: m};

    final result = <StageData>[];

    for (final doc in snapshot.docs) {
      final stageId = doc.id;
      final data = doc.data();

      final sm = byId[stageId];
      if (sm == null) continue;

      // 마스터 → StageData 변환
      final base = _fromMaster(sm);

      // 진행 오버레이
      final ac = _acFromProgress(data);
      final status = _statusFromString((data['status'] ?? 'locked').toString());
      final achievement = (data['achievement'] is int)
          ? data['achievement'] as int
          : int.tryParse((data['achievement'] ?? '0').toString()) ?? 0;

      result.add(base.copyWith(
        activityCompleted: ac,
        status: status,
        achievement: achievement,
      ));
    }

    return result;
  });
});

// -----------------------------
// Helpers
// -----------------------------

// StageMaster → StageData 투영
StageData _fromMaster(StageMaster sm) {
  return StageData(
    stageId: sm.id,
    subdetailTitle: sm.subdetailTitle,
    totalTime: sm.totalTime,
    difficultyLevel: sm.difficultyLevel, // ✅ 새 필드 사용
    textContents: sm.textContents,       // ✅ 새 필드 사용
    missions: sm.missions,
    effects: sm.effects,
    activityCompleted: const {
      'beforeReading': false,
      'duringReading': false,
      'afterReading': false,
    },
    brData: sm.brData,
    readingData: sm.readingData,
    arData: sm.arData,
  );
}

// 문자열 → enum
StageStatus _statusFromString(String s) {
  switch (s) {
    case 'inProgress':
      return StageStatus.inProgress;
    case 'completed':
      return StageStatus.completed;
    case 'locked':
    default:
      return StageStatus.locked;
  }
}

/// 진행도(activityCompleted) 맵을 우선 읽고,
/// 문서 최상위(beforeReading/duringReading/afterReading)가 있으면 폴백으로 사용.
Map<String, bool> _acFromProgress(Map<String, dynamic> p) {
  final raw = p['activityCompleted'];
  final ac = (raw is Map<String, dynamic>) ? raw : const <String, dynamic>{};

  bool asBool(dynamic v) => v == true;

  final before = asBool(ac['beforeReading'] ?? p['beforeReading']);
  final during = asBool(ac['duringReading'] ?? p['duringReading']);
  final after  = asBool(ac['afterReading']  ?? p['afterReading']);

  return {
    'beforeReading': before,
    'duringReading': during,
    'afterReading' : after,
  };
}

void _debugCheckCollectionPath(String path, {String tag = ''}) {
  final segs = path.split('/').where((s) => s.isNotEmpty).length;
  if (kDebugMode) {
    debugPrint('[PATH][$tag] $path | segments=$segs | ${segs.isOdd ? "COLLECTION" : "DOCUMENT"}');
  }
  assert(segs.isOdd, 'Expected a COLLECTION path, but got DOCUMENT: $path');
}

void _debugCheckDocPath(String path, {String tag = ''}) {
  final segs = path.split('/').where((s) => s.isNotEmpty).length;
  if (kDebugMode) {
    debugPrint('[PATH][$tag] $path | segments=$segs | ${segs.isEven ? "DOCUMENT" : "COLLECTION"}');
  }
  assert(segs.isEven, 'Expected a DOCUMENT path, but got COLLECTION: $path');
}
