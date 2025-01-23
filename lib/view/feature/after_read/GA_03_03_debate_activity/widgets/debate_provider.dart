import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'debate_notifier.dart';
import 'debate_state.dart';

/// Debate 상태 Provider
final debateProvider =
StateNotifierProvider<DebateNotifier, DebateState>((ref) {
  return DebateNotifier();
});
