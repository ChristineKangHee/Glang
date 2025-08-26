// lib/services/learning_assembly_service.dart
import 'package:flutter/foundation.dart';
import '../model/section_data.dart';      // SectionData
import '../model/stage_data.dart';        // StageData, StageStatus
import '../model/stage_master.dart';      // StageMaster (stages/{id} 스키마)
import '../model/localized_types.dart';   // LocalizedText
import 'stage_repository.dart';

class LearningAssemblyService {
  LearningAssemblyService._();
  static final LearningAssemblyService instance = LearningAssemblyService._();

  /// 섹션 마스터 없이, 'stages'만으로 공용 섹션 조립
  Future<List<SectionData>> buildPublicSections() async {
    final allStages = await StageRepository.instance.getAllStagesOnce();
    if (allStages.isEmpty) return const [];

    // 1) 정렬: stage_001, stage_002 ... 숫자 기준
    allStages.sort((a, b) => _stageNumber(a.id).compareTo(_stageNumber(b.id)));

    // 2) 그룹핑 규칙: 4개 단위(001~004 → 1섹션, 005~008 → 2섹션, …)
    //    만약 StageMaster에 section 필드가 있다면: final secIdx = a.section ?? _sectionIndexFromId(a.id);
    final Map<int, List<StageMaster>> bySection = {};
    for (final sm in allStages) {
      final secIdx = _sectionIndexFromId(sm.id);
      bySection.putIfAbsent(secIdx, () => <StageMaster>[]).add(sm);
    }

    // 3) SectionData로 변환 (섹션 번호 오름차순)
    final entries = bySection.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((e) {
      final sectionIdx = e.key;
      final stageDatas = e.value.map(_toStageData).toList(growable: false);
      return SectionData(
        section: sectionIdx,
        title: LocalizedText(ko: '섹션 $sectionIdx', en: 'Section $sectionIdx'),
        sectionDetail: const LocalizedText(), // 필요 시 설명 넣기
        stages: stageDatas,
      );
    }).toList(growable: false);
  }

  /// (선택) 사용자 지정 섹션: uid와 sectionIds가 아니라,
  /// users/{uid}/progress/sections 의 order를 기반으로 묶고 싶다면
  /// 별도 함수로 구현하면 됩니다. (지금은 불필요하면 제거해도 OK)
  Future<List<SectionData>> buildUserSectionsByOrderMap({
    required Map<String,int> orderByStageId, // stageId → order
    int chunkSize = 4, // 4개씩 한 섹션
  }) async {
    final all = await StageRepository.instance.getAllStagesOnce();
    final byId = {for (final s in all) s.id: s};

    // order 기준으로 stageId 정렬
    final sortedIds = orderByStageId.keys.toList()
      ..sort((a, b) => (orderByStageId[a] ?? 1<<30).compareTo(orderByStageId[b] ?? 1<<30));

    final result = <SectionData>[];
    for (int i = 0; i < sortedIds.length; i += chunkSize) {
      final chunk = sortedIds.sublist(i, (i + chunkSize).clamp(0, sortedIds.length));
      final sectionIdx = (i ~/ chunkSize) + 1;
      final stages = <StageData>[];
      for (final id in chunk) {
        final sm = byId[id];
        if (sm != null) stages.add(_toStageData(sm));
      }
      result.add(SectionData(
        section: sectionIdx,
        title: LocalizedText(ko: '섹션 $sectionIdx', en: 'Section $sectionIdx'),
        sectionDetail: const LocalizedText(),
        stages: stages,
      ));
    }
    return result;
  }

  // ----------------- Helpers -----------------

  StageData _toStageData(StageMaster sm) {
    return StageData(
      stageId: sm.id,
      subdetailTitle: sm.subdetailTitle,   // LocalizedText
      totalTime: sm.totalTime,             // String
      difficultyLevel: sm.difficultyLevel ?? const LocalizedText(),
      textContents: sm.textContents ?? const LocalizedText(),
      missions: sm.missions,               // LocalizedList<List<String>> 형태였다면 변환 필요
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

  /// stage_001 → 1, stage_012 → 12
  int _stageNumber(String id) {
    final match = RegExp(r'\d+').firstMatch(id)?.group(0);
    return int.tryParse(match ?? '0') ?? 0;
  }

  /// 4개 단위로 섹션 번호 (001~004=1, 005~008=2, ...)
  int _sectionIndexFromId(String id) {
    final n = _stageNumber(id);
    if (n <= 0) return 0;
    return ((n - 1) ~/ 4) + 1;
  }
}
