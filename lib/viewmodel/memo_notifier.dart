import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/memo_model.dart';
import 'memo_service.dart';

final memoProvider = StateNotifierProvider<MemoNotifier, List<Memo>>(
      (ref) => MemoNotifier(),
);

class MemoNotifier extends StateNotifier<List<Memo>> {
  final MemoService _memoService = MemoService();

  MemoNotifier() : super([]) {
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    try {
      final memos = await _memoService.fetchMemos();
      state = memos;
    } catch (e) {
      // 에러 처리 필요 시 추가
      state = [];
    }
  }

  Future<void> addMemo({
    required String stageId,
    required String subdetailTitle,
    required String selectedText,
    required String note,
  }) async {
    final newMemo = Memo(
      id: const Uuid().v4(),
      stageId: stageId,
      subdetailTitle: subdetailTitle,
      selectedText: selectedText,
      note: note,
      createdAt: DateTime.now(),
    );
    await _memoService.addMemo(newMemo);
    state = [...state, newMemo];
  }

  Future<void> updateMemo(String id, String newNote) async {
    final memoIndex = state.indexWhere((memo) => memo.id == id);
    if (memoIndex == -1) return;
    final updatedMemo = Memo(
      id: state[memoIndex].id,
      stageId: state[memoIndex].stageId,
      subdetailTitle: state[memoIndex].subdetailTitle,
      selectedText: state[memoIndex].selectedText,
      note: newNote,
      createdAt: state[memoIndex].createdAt,
    );
    await _memoService.updateMemo(updatedMemo);
    state = [
      for (final memo in state)
        if (memo.id == id)
          updatedMemo
        else
          memo,
    ];
  }

  Future<void> deleteMemo(String id) async {
    await _memoService.deleteMemo(id);
    state = state.where((memo) => memo.id != id).toList();
  }
}
