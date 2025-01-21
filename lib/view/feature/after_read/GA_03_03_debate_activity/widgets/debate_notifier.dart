// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'debate_state.dart';
// import 'debate_model.dart';
// import 'package:readventure/api/debate_chatgpt_service.dart';
//
// // DebateNotifier에 GPT 서비스 주입
// class DebateNotifier extends StateNotifier<DebateState> {
//   final DebateGPTService _debateGPTService;
//
//   DebateNotifier(this._debateGPTService) : super(DebateState.initial());
//
//   Future<void> startRound() async {
//     if (state.currentRound >= 4) {
//       state = state.copyWith(isDebateOver: true);
//       return;
//     }
//
//     final updatedRounds = [...state.rounds];
//
//     if (!state.isUserTurn) {
//       // AI 응답 생성
//       final aiResponse = await _debateGPTService.getDebateResponse(
//         state.topic,
//         isAgree: state.currentRound % 2 == 0,
//       );
//       updatedRounds[state.currentRound].setAiResponse(aiResponse);
//
//       // 상태 업데이트
//       state = state.copyWith(
//         rounds: updatedRounds,
//         currentRound: state.currentRound + 1,
//         isUserTurn: true,
//       );
//     } else {
//       // 사용자 응답을 저장했을 때
//       state = state.copyWith(
//         rounds: updatedRounds,
//         isUserTurn: false,
//       );
//     }
//   }
//
// }
