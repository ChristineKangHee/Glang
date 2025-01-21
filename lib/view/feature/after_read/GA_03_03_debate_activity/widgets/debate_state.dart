// import 'debate_model.dart';
//
// class DebateState {
//   final String topic;
//   final int currentRound;
//   final bool isUserTurn;
//   final bool isDebateOver;
//   final List<DebateRound> rounds;
//
//   DebateState({
//     required this.topic,
//     required this.currentRound,
//     required this.isUserTurn,
//     required this.isDebateOver,
//     required this.rounds,
//   });
//
//   factory DebateState.initial() {
//     return DebateState(
//       topic: "",
//       currentRound: 0,
//       isUserTurn: true,
//       isDebateOver: false,
//       rounds: List.generate(4, (index) => DebateRound(roundNumber: index + 1)),
//     );
//   }
//
//   DebateState copyWith({
//     String? topic,
//     int? currentRound,
//     bool? isUserTurn,
//     bool? isDebateOver,
//     List<DebateRound>? rounds,
//   }) {
//     return DebateState(
//       topic: topic ?? this.topic,
//       currentRound: currentRound ?? this.currentRound,
//       isUserTurn: isUserTurn ?? this.isUserTurn,
//       isDebateOver: isDebateOver ?? this.isDebateOver,
//       rounds: rounds ?? this.rounds,
//     );
//   }
// }
