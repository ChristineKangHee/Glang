
/// Debate 상태 관리
class DebateState {
  final int currentRound;
  final bool isUserPro;
  final int timerKey;
  final bool isFinished;
  final bool isPaused; // 타이머 일시정지 상태

  DebateState({
    required this.currentRound,
    required this.isUserPro,
    required this.timerKey,
    required this.isFinished,
    required this.isPaused,
  });

  /// 상태 복사본 생성
  DebateState copyWith({
    int? currentRound,
    bool? isUserPro,
    int? timerKey,
    bool? isFinished,
    bool? isPaused,
  }) {
    return DebateState(
      currentRound: currentRound ?? this.currentRound,
      isUserPro: isUserPro ?? this.isUserPro,
      timerKey: timerKey ?? this.timerKey,
      isFinished: isFinished ?? this.isFinished,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  /// 초기 상태
  factory DebateState.initial() {
    return DebateState(
      currentRound: 1,
      isUserPro: true,
      timerKey: 0,
      isFinished: false,
      isPaused: false, // 초기 상태: 일시정지 아님
    );
  }
}