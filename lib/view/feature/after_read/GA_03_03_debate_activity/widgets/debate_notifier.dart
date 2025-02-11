// debate_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'debate_state.dart';

/// Debate 상태 관리용 StateNotifier
class DebateNotifier extends StateNotifier<DebateState> {
  Timer? _timer; // 내부 타이머 객체

  DebateNotifier() : super(DebateState.initial());

  /// 라운드 전환 및 상태 갱신
  void nextRound() {
    if (state.currentRound >= 4) {
      // 4라운드 이후 토론 종료
      state = state.copyWith(isFinished: true);
    } else {
      // 라운드 전환 및 입장 변경
      state = state.copyWith(
        currentRound: state.currentRound + 1,
        isUserPro: !state.isUserPro,
        timerKey: state.timerKey + 1,
      );
    }
  }

  /// 타이머 일시정지
  void pauseTimer() {
    state = state.copyWith(isPaused: true); // 일시정지 상태로 변경
    _timer?.cancel(); // 타이머 정지
  }

  /// 타이머 재개
  void resumeTimer() {
    state = state.copyWith(isPaused: false); // 일시정지 해제
    state = state.copyWith(timerKey: state.timerKey + 1); // 타이머 재시작
  }

  /// 상태 초기화
  void reset() {
    state = DebateState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 머 해제
    super.dispose();
  }

}

