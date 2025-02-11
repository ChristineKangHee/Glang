//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:readventure/view/feature/reading/quiz_data.dart';
// import 'package:readventure/view/feature/reading/result_dialog.dart';
// import 'package:readventure/view/feature/reading/GA_02_02_subjective/subjective_quiz.dart';
// import 'package:readventure/view/feature/reading/GA_02/toolbar_component.dart';
// import '../../../../../theme/font.dart';
// import '../../../../../theme/theme.dart';
// import '../../../components/custom_app_bar.dart';
// import '../../../components/custom_button.dart';
// import '../../after_read/choose_activities.dart';
// import '../GA_02_04_reading_Quiz_mcq/mcq_quiz.dart';
// import '../GA_02_04_reading_Quiz_ox/ox_quiz.dart';
//
// class RdMain extends StatefulWidget {
//   final List<OxQuestion> oxQuestions; // OX 퀴즈 질문 리스트
//   final List<McqQuestion> mcqQuestions; // MCQ 퀴즈 질문 리스트
//
//   RdMain({required this.oxQuestions, required this.mcqQuestions});
//
//   @override
//   _RdMainState createState() => _RdMainState();
// }
//
// class _RdMainState extends State<RdMain> with SingleTickerProviderStateMixin {
//   bool _showOxQuiz = false; // OX 퀴즈 표시 여부
//   bool _showMcqQuiz = false; // MCQ 퀴즈 표시 여부
//   bool _showSubjectiveQuiz = false; // 주관식 퀴즈 표시 여부
//   int currentOxQuestionIndex = 0; // 현재 OX 질문 인덱스
//   int currentMcqQuestionIndex = 0; // 현재 MCQ 질문 인덱스
//   List<bool> oxUserAnswers = []; // OX 퀴즈 사용자 답변 리스트
//   List<int> mcqUserAnswers = []; // MCQ 퀴즈 사용자 답변 리스트
//   late AnimationController _animationController; // 애니메이션 컨트롤러
//   late Animation<double> _animation; // 애니메이션
//   final TextEditingController _subjectiveController = TextEditingController(); // 주관식 답변 입력 컨트롤러
//   String? subjectiveAnswer; // 주관식 답변 저장
//
//   // 퀴즈 완료 상태 추적
//   bool oxCompleted = false; // OX 퀴즈 완료 여부
//   bool mcqCompleted = false; // MCQ 퀴즈 완료 여부
//   bool subjectiveCompleted = false; // 주관식 퀴즈 완료 여부
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
//       vsync: this, // 애니메이션 컨트롤러 초기화
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut, // 애니메이션 커브 설정
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose(); // 애니메이션 컨트롤러 해제
//     _subjectiveController.dispose(); // 주관식 컨트롤러 해제
//     super.dispose();
//   }
//
//   // OX 퀴즈 정답 체크 및 처리
//   void checkOxAnswer(bool selectedAnswer) {
//     final question = widget.oxQuestions[currentOxQuestionIndex];
//     bool isCorrect = selectedAnswer == question.correctAnswer; // 정답 체크
//
//     setState(() {
//       // 현재 인덱스에 답 저장
//       if (oxUserAnswers.length > currentOxQuestionIndex) {
//         oxUserAnswers[currentOxQuestionIndex] = selectedAnswer;
//       } else {
//         // 새로운 답 추가
//         oxUserAnswers.add(selectedAnswer);
//       }
//       oxCompleted = true; // OX 퀴즈 완료로 설정
//     });
//
//     ResultDialog.show(context, isCorrect, question.explanation, () {
//       setState(() {
//         _showOxQuiz = false;
//         _animationController.reverse(); // 퀴즈 종료 시 애니메이션 뒤로 이동
//       });
//     });
//   }
//
//   // MCQ 퀴즈 정답 체크 및 처리
//   void checkMcqAnswer(int selectedIndex) {
//     final question = widget.mcqQuestions[currentMcqQuestionIndex];
//     bool isCorrect = selectedIndex == question.correctAnswerIndex; // 정답 체크
//
//     setState(() {
//       // 현재 인덱스에 답 저장
//       if (mcqUserAnswers.length > currentMcqQuestionIndex) {
//         mcqUserAnswers[currentMcqQuestionIndex] = selectedIndex;
//       } else {
//         // 새로운 답 추가
//         mcqUserAnswers.add(selectedIndex);
//       }
//       mcqCompleted = true; // MCQ 퀴즈 완료로 설정
//     });
//
//     ResultDialog.show(context, isCorrect, question.explanation, () {
//       setState(() {
//         _showMcqQuiz = false;
//         _animationController.reverse(); // 퀴즈 종료 시 애니메이션 뒤로 이동
//       });
//     });
//   }
//
//   // 퀴즈 표시 여부 토글
//   void toggleQuizVisibility(String quizType) {
//     setState(() {
//       if (quizType == 'OX') {
//         _showOxQuiz = !_showOxQuiz; // OX 퀴즈 토글
//         _showMcqQuiz = false;
//         _showSubjectiveQuiz = false;
//       } else if (quizType == 'MCQ') {
//         _showMcqQuiz = !_showMcqQuiz; // MCQ 퀴즈 토글
//         _showOxQuiz = false;
//         _showSubjectiveQuiz = false;
//       } else {
//         _showSubjectiveQuiz = !_showSubjectiveQuiz; // 주관식 퀴즈 토글
//         _showOxQuiz = false;
//         _showMcqQuiz = false;
//       }
//       if (_showOxQuiz || _showMcqQuiz || _showSubjectiveQuiz) {
//         _animationController.forward(); // 퀴즈 표시 시 애니메이션 전환
//       } else {
//         _animationController.reverse(); // 퀴즈 숨길 때 애니메이션 뒤로 이동
//       }
//     });
//   }
//
//   // 주관식 답변 제출 처리
//   void submitSubjectiveAnswer() {
//     final answer = _subjectiveController.text.trim(); // 주관식 답변 읽어오기
//     setState(() {
//       subjectiveAnswer = answer; // 주관식 답변 저장
//       subjectiveCompleted = true; // 주관식 퀴즈 완료로 설정
//     });
//
//     // 답변 제출 완료 알림 다이얼로그
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: Text('답변 제출 완료'),
//         content: Text('주관식 답변이 제출되었습니다.\n\n답변: $answer'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // 다이얼로그 닫기
//               toggleQuizVisibility('SUBJECTIVE'); // 퀴즈 숨기기
//             },
//             child: Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//
//     return Scaffold(
//       appBar: CustomAppBar_2depth_8(
//         title: "읽기 도구의 필요성", // 앱 바 타이틀
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 첫 번째 텍스트: 선택 가능 텍스트
//             SelectableText(
//               '현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다.',
//               style: reading_textstyle(context).copyWith(color: customColors.neutral0),
//               selectionControls: Read_Toolbar(customColors: customColors),
//               cursorColor: customColors.primary, // 커서 색상
//             ),
//             const SizedBox(height: 16),
//             SelectableText.rich(
//               // 두 번째 텍스트: rich 텍스트로 구성된 부분
//               TextSpan(
//                 style: reading_textstyle(context).copyWith(
//                   color: customColors.neutral0,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: '기존의 교육 시스템은 주로 일률적인 교재와 평가 방식을 사용하며, 이는 학습 동기를 저하시킬 위험이 있다. ',
//                   ),
//                   WidgetSpan(
//                     alignment: PlaceholderAlignment.middle,
//                     child: GestureDetector(
//                       onTap: () => toggleQuizVisibility('OX'), // OX 퀴즈 토글
//                       child: Column(
//                         children: [
//                           _buildQuizButton(customColors, 'OX', oxCompleted),
//                           SizeTransition(
//                             sizeFactor: _animation,
//                             child: _showOxQuiz
//                                 ? OxQuiz(
//                               question: widget.oxQuestions[currentOxQuestionIndex],
//                               onAnswerSelected: checkOxAnswer,
//                               userAnswer: oxUserAnswers.length > currentOxQuestionIndex
//                                   ? oxUserAnswers[currentOxQuestionIndex]
//                                   : null,
//                             )
//                                 : SizedBox.shrink(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   TextSpan(
//                     text: '또한, 읽기 과정에서 즉각적인 피드백을 제공하는 시스템이 부족하여 학습자는 자신의 약점이나 강점을 파악하기 어렵다.',
//                   ),
//                   WidgetSpan(
//                     alignment: PlaceholderAlignment.middle,
//                     child: GestureDetector(
//                       onTap: () => toggleQuizVisibility('SUBJECTIVE'), // 주관식 퀴즈 토글
//                       child: Column(
//                         children: [
//                           _buildQuizButton(customColors, 'SUBJECTIVE', subjectiveCompleted),
//                           SizeTransition(
//                             sizeFactor: _animation,
//                             child: _showSubjectiveQuiz
//                                 ? SubjectiveQuiz(
//                               controller: _subjectiveController,
//                               onSubmit: submitSubjectiveAnswer,
//                               initialAnswer: subjectiveAnswer, // 초기 답변 전달
//                               enabled: !subjectiveCompleted, // 완료된 경우 비활성화
//                             )
//                                 : SizedBox.shrink(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   TextSpan(
//                     text: '맞춤형 읽기 도구와 실시간 피드백 시스템은 학습자가 적합한 자료를 통해 능동적으로 읽기 능력을 향상시키고, 스스로 학습 과정을 조율할 수 있는 환경을 제공할 잠재력이 있다. 또한, 맞춤형 읽기 도구는 학습자의 수준과 흥미를 고려하여 적합한 자료를 제공할 수 있다.',
//                   ),
//                   WidgetSpan(
//                     alignment: PlaceholderAlignment.middle,
//                     child: GestureDetector(
//                       onTap: () => toggleQuizVisibility('MCQ'), // MCQ 퀴즈 토글
//                       child: Column(
//                         children: [
//                           _buildQuizButton(customColors, 'MCQ', mcqCompleted),
//                           SizeTransition(
//                             sizeFactor: _animation,
//                             child: _showMcqQuiz
//                                 ? McqQuiz(
//                               question: widget.mcqQuestions[currentMcqQuestionIndex],
//                               onAnswerSelected: checkMcqAnswer,
//                               userAnswer: mcqUserAnswers.length > currentMcqQuestionIndex
//                                   ? mcqUserAnswers[currentMcqQuestionIndex]
//                                   : null,
//                             )
//                                 : SizedBox.shrink(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               selectionControls: Read_Toolbar(customColors: customColors),
//             ),
//             SizedBox(height: 40,),
//             // '읽기 완료' 버튼
//             ButtonPrimary_noPadding(
//               function: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     settings: RouteSettings(name: 'LearningActivitiesPage'),
//                     builder: (context) => LearningActivitiesPage(),
//                   ),
//                 );
//               },
//               title: "읽기 완료", // 버튼 타이틀
//             ),
//             SizedBox(height: 40,),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 퀴즈 버튼 빌드
//   Widget _buildQuizButton(CustomColors customColors, String quizType, bool isCompleted) {
//     return Container(
//       width: 30, // 버튼의 가로 크기
//       height: 30, // 버튼의 세로 크기
//       decoration: BoxDecoration(
//         color: isCompleted ? customColors.primary20 : customColors.primary,
//         shape: BoxShape.circle,
//       ),
//       alignment: Alignment.center, // 아이콘을 중앙에 배치
//       child: Icon(Icons.star, color: customColors.secondary, size: 14),
//     );
//   }
// }
//
// // 텍스트 선택 툴바를 구현한 클래스
// class Read_Toolbar extends MaterialTextSelectionControls {
//   final customColors;
//
//   Read_Toolbar({required this.customColors});
//
//   @override
//   Widget buildToolbar(
//       BuildContext context,
//       Rect globalEditableRegion,
//       double textLineHeight,
//       Offset position,
//       List<TextSelectionPoint> endpoints,
//       TextSelectionDelegate delegate,
//       ValueListenable<ClipboardStatus>? clipboardStatus,
//       Offset? lastSecondaryTapDownPosition,
//       ) {
//     const double toolbarHeight = 50;
//     const double toolbarWidth = 135;
//
//     // Get the screen size to limit the toolbar's position
//     final screenSize = MediaQuery.of(context).size;
//
//     // Calculate the ideal position for the toolbar
//     double leftPosition = (endpoints.first.point.dx + endpoints.last.point.dx) / 2 - toolbarWidth / 2+16;
//     double topPosition = endpoints.first.point.dy + globalEditableRegion.top - toolbarHeight - 32.0;
//
//     // Ensure the toolbar stays within the screen boundaries (left, top, and right)
//     leftPosition = leftPosition.clamp(0.0, screenSize.width - toolbarWidth);
//     topPosition = topPosition.clamp(0.0, screenSize.height - toolbarHeight);
//
//     return Stack(
//       children: [
//         Positioned(
//           left: leftPosition,
//           top: topPosition,
//           child: Toolbar(
//             toolbarWidth: toolbarWidth,
//             toolbarHeight: toolbarHeight,
//             context: context,
//             delegate: delegate,
//             customColors: customColors,
//           ),
//         ),
//       ],
//     );
//   }
// }