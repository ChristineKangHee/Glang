// lib/view/feature/after_read/GA_03_04_diagram/submission_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../../model/section_data.dart';
import '../../../../model/stage_data.dart';
import '../../../home/stage_provider.dart';
import '../choose_activities.dart';
import 'diagram_learning.dart';

enum SubmissionStatus { initial, submitting, success, failure }

class SubmissionNotifier extends StateNotifier<SubmissionStatus> {
  SubmissionNotifier(this.ref) : super(SubmissionStatus.initial);
  final Ref ref;

  /// [correctAnswersMap]는 다이어그램 데이터에 포함된 정답 정보입니다.
  Future<void> submitFeature(Map<String, String> correctAnswersMap) async {
    state = SubmissionStatus.submitting;
    try {
      // 단어 배치 상태(노드 라벨)를 읽어서 정답 확인
      final nodeLabels = ref.read(nodeLabelProvider);
      bool allCorrect = true;
      for (var nodeId in correctAnswersMap.keys) {
        if (nodeLabels[nodeId] != correctAnswersMap[nodeId]) {
          allCorrect = false;
          break;
        }
      }
      // 제출 상태 프로바이더 업데이트 (이 값은 UI에서 버튼 텍스트 등에도 사용됨)
      ref.read(submissionStatusProvider.notifier).state = true;
      ref.read(submissionCompleteProvider.notifier).state = allCorrect;

      // 정답이 아니면 작업 종료
      if (!allCorrect) {
        state = SubmissionStatus.failure;
        return;
      }

      // 정답인 경우, 스테이지 업데이트 진행
      final selectedId = ref.read(selectedStageIdProvider);
      final freshStages = await ref.refresh(stagesProvider.future);
      StageData? freshStage;
      if (selectedId != null) {
        freshStage = freshStages.firstWhereOrNull(
              (stage) => stage.stageId == selectedId,
        );
      }
      if (freshStage != null) {
        await updateFeatureCompletion(
          stageId: freshStage.stageId,
          featureNumber: 4,
          isCompleted: true,
        );

        // update 후 stagesProvider를 invalidate하여 최신 상태를 반영합니다.
        ref.invalidate(stagesProvider);
      }
      ref.read(wordListProvider.notifier).resetWords();
      ref.read(nodeLabelProvider.notifier).clearNodeLabels();

      state = SubmissionStatus.success;
    } catch (e) {
      state = SubmissionStatus.failure;
    }
  }
}

// SubmissionNotifier를 전역적으로 관리할 Provider
final submissionNotifierProvider =
StateNotifierProvider<SubmissionNotifier, SubmissionStatus>(
      (ref) => SubmissionNotifier(ref),
);
