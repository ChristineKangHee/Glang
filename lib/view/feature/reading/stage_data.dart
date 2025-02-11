// import 'package:readventure/view/feature/reading/quiz_data.dart';
//
// class StageData {
//   final String title; // 스테이지 제목
//   final String content; // 본문 내용 (3개의 본문을 "\n\n"으로 구분)
//   final List<OxQuestion> oxQuestions; // OX 퀴즈 목록
//   final List<McqQuestion> mcqQuestions; // 객관식 퀴즈 목록
//
//   StageData({
//     required this.title,
//     required this.content,
//     required this.oxQuestions,
//     required this.mcqQuestions,
//   });
// }
//
// // 스테이지별 본문 및 퀴즈 데이터 저장
// List<StageData> stages = [
//   StageData(
//     title: "스테이지 1 - 읽기 도구의 필요성",
//     content: """현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다.
//
// 맞춤형 읽기 도구는 개별 학습자의 필요에 맞춘 자료를 제공할 수 있으며, 기존의 교육 시스템에서 부족했던 개인 맞춤형 지원을 강화한다.
//
// 이러한 도구를 활용하면 학습자는 더욱 능동적으로 학습을 진행할 수 있으며, 스스로 피드백을 받아 학습 전략을 조정할 수 있다.""",
//
//     mcqQuestions: [
//       McqQuestion(
//         paragraph: "맞춤형 읽기 도구의 특징으로 가장 적합한 설명은?",
//         options: [
//           "학습자의 흥미와 수준을 반영한다.",
//           "단순한 교재 제공에 그친다.",
//           "실시간 피드백을 제공하지 않는다.",
//           "일률적인 교재를 기반으로 한다."
//         ],
//         correctAnswerIndex: 0,
//         explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",
//       ),
//     ],
//     oxQuestions: [
//       OxQuestion(
//         paragraph: "기존의 일률적인 교재와 평가 방식은 학습자의 동기를 높이는 데 효과적이다.",
//         correctAnswer: false,
//         explanation: "기존의 교재 방식은 학습자의 흥미를 고려하지 않아 동기를 저하시킬 수 있습니다.",
//       ),
//     ],
//   ),
//
//   StageData(
//     title: "스테이지 2 - 코코의 이야기",
//     content: """코코는 작은 강아지입니다. 코코는 아침마다 공원에서 뛰어노는 것을 좋아합니다.
//
// 코코는 다양한 동물 친구들과 함께 놀며, 특히 공놀이를 가장 좋아합니다.
//
// 코코는 가족과 함께 시간을 보내는 것을 좋아하며, 주인의 목소리를 듣는 것이 가장 행복한 순간입니다.""",
//
//     mcqQuestions: [
//       McqQuestion(
//         paragraph: "코코는 어떤 동물인가요?",
//         options: ["고양이", "강아지", "토끼"],
//         correctAnswerIndex: 1,
//         explanation: "코코는 강아지입니다.",
//       ),
//     ],
//     oxQuestions: [
//       OxQuestion(
//         paragraph: "코코는 고양이다.",
//         correctAnswer: false,
//         explanation: "코코는 강아지입니다.",
//       ),
//     ],
//   ),
// ];
