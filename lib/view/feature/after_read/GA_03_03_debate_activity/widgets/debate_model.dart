// class DebateRound {
//   final int roundNumber; // 라운드 번호
//   String? userResponse;  // 사용자의 응답
//   String? aiResponse;    // AI의 응답
//   bool isUserTurn;       // 현재 라운드에서 사용자의 턴인지 여부
//
//   DebateRound({
//     required this.roundNumber,
//     this.userResponse,
//     this.aiResponse,
//     this.isUserTurn = true,
//   });
//
//   /// 사용자 응답 저장
//   void setUserResponse(String response) {
//     userResponse = response;
//   }
//
//   /// AI 응답 저장
//   void setAiResponse(String response) {
//     aiResponse = response;
//   }
//
//   /// 라운드가 완료되었는지 확인
//   bool isComplete() {
//     return userResponse != null && aiResponse != null;
//   }
//
//   @override
//   String toString() {
//     return 'Round $roundNumber:\n'
//         '- User: ${userResponse ?? "No response yet"}\n'
//         '- AI: ${aiResponse ?? "No response yet"}\n';
//   }
// }
