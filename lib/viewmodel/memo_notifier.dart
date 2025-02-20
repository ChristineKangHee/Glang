import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/memo_model.dart';
import 'memo_service.dart';

// 메모 목록을 관리하는 StateNotifierProvider 정의
final memoProvider = StateNotifierProvider<MemoNotifier, List<Memo>>(
      (ref) => MemoNotifier(),
);

// 메모 상태를 관리하는 StateNotifier 클래스
class MemoNotifier extends StateNotifier<List<Memo>> {
  final MemoService _memoService = MemoService(); // 메모 관련 서비스 객체 생성

  // 생성자에서 초기 메모 목록을 불러옴
  MemoNotifier() : super([]) {
    _loadMemos();
  }

  // 메모 목록을 불러오는 비동기 함수
  Future<void> _loadMemos() async {
    try {
      final memos = await _memoService.fetchMemos(); // 메모 데이터 가져오기
      state = memos; // 상태 업데이트
    } catch (e) {
      // 에러 발생 시 빈 리스트로 설정 (필요 시 에러 처리 추가 가능)
      state = [];
    }
  }

  // 새로운 메모 추가
  Future<void> addMemo({
    required String stageId,
    required String subdetailTitle,
    required String selectedText,
    required String note,
  }) async {
    final newMemo = Memo(
      id: const Uuid().v4(), // UUID를 이용해 고유 ID 생성
      stageId: stageId,
      subdetailTitle: subdetailTitle,
      selectedText: selectedText,
      note: note,
      createdAt: DateTime.now(), // 현재 시간 기록
    );

    await _memoService.addMemo(newMemo); // 서비스에 메모 추가 요청
    state = [...state, newMemo]; // 상태에 새로운 메모 추가
  }

  // 기존 메모 수정
  Future<void> updateMemo(String id, String newNote) async {
    final memoIndex = state.indexWhere((memo) => memo.id == id); // 해당 메모 찾기
    if (memoIndex == -1) return; // 존재하지 않으면 종료

    final updatedMemo = Memo(
      id: state[memoIndex].id,
      stageId: state[memoIndex].stageId,
      subdetailTitle: state[memoIndex].subdetailTitle,
      selectedText: state[memoIndex].selectedText,
      note: newNote, // 새로운 노트 내용 적용
      createdAt: state[memoIndex].createdAt,
    );

    await _memoService.updateMemo(updatedMemo); // 서비스에 수정 요청
    state = [
      for (final memo in state)
        if (memo.id == id) updatedMemo else memo, // 해당 메모만 업데이트
    ];
  }

  // 메모 삭제
  Future<void> deleteMemo(String id) async {
    await _memoService.deleteMemo(id); // 서비스에 삭제 요청
    state = state.where((memo) => memo.id != id).toList(); // 상태에서 제거
  }
}
