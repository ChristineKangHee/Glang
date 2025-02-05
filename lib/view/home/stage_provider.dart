// stage_provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/section_data.dart';
import '../../model/stage_data.dart';
import 'package:collection/collection.dart';
// 혹은 stage_data.dart를 import해서 loadStagesFromFirestore를 직접 불러올 수도 있음

/// 0) userIdProvider: 현재 로그인한 유저의 UID를 저장하는 StateProvider
///    - 로그인 시점에 set해주면 됨.
final userIdProvider = StateProvider<String?>((ref) => null);

/// 1) stagesProvider: userIdProvider를 구독 → userId가 있으면 loadStagesFromFirestore 호출
final stagesProvider = FutureProvider<List<StageData>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    // 아직 userId가 없으면 빈 리스트 반환 (로그인 전 상태)
    return [];
  }

  // 실제 Firestore 로드
  return await loadStagesFromFirestore(userId);
});

/// 2) selectedStageIdProvider: 현재 선택한 스테이지 ID (예: 'stage_001')
final selectedStageIdProvider = StateProvider<String?>((ref) => null);

/// 3) currentStageProvider: stagesProvider 결과에서 selectedStageId와 일치하는 StageData를 반환
final currentStageProvider = Provider<StageData?>((ref) {
  final stageId = ref.watch(selectedStageIdProvider);
  final stagesAsync = ref.watch(stagesProvider);

  // 로딩 중이거나, 아직 userId나 stageId가 없으면 null
  if (stageId == null || stagesAsync.isLoading) {
    return null;
  }

  final allStages = stagesAsync.value ?? [];
  return allStages.firstWhereOrNull((stage) => stage.stageId == stageId);
});
