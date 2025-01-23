import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debate 상태 관리
class DebateState {
  final int currentRound;
  final bool isUserPro;
  final int timerKey;
  final bool isFinished;

  DebateState({
    required this.currentRound,
    required this.isUserPro,
    required this.timerKey,
    required this.isFinished,
  });

  /// 상태 복사본 생성
  DebateState copyWith({
    int? currentRound,
    bool? isUserPro,
    int? timerKey,
    bool? isFinished,
  }) {
    return DebateState(
      currentRound: currentRound ?? this.currentRound,
      isUserPro: isUserPro ?? this.isUserPro,
      timerKey: timerKey ?? this.timerKey,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  /// 초기 상태
  factory DebateState.initial() {
    return DebateState(
      currentRound: 1,
      isUserPro: true,
      timerKey: 0,
      isFinished: false,
    );
  }
}

/// Debate 상태 관리용 StateNotifier
class DebateNotifier extends StateNotifier<DebateState> {
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

  /// 상태 초기화
  void reset() {
    state = DebateState.initial();
  }
}

/// Debate 상태 Provider
final debateProvider =
StateNotifierProvider<DebateNotifier, DebateState>((ref) {
  return DebateNotifier();
});
