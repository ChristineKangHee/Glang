/// File: quiz_data.dart
/// Purpose: 읽기중 퀴즈에 들어갈 데이터 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

class OxQuestion {
  final String paragraph;
  final bool correctAnswer;
  final String explanation;

  OxQuestion({required this.paragraph, required this.correctAnswer, required this.explanation});
}

class McqQuestion {
  final String paragraph;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  McqQuestion({required this.paragraph, required this.options, required this.correctAnswerIndex, required this.explanation});
}

// List<OxQuestion> ox = [
// //   OxQuestion(paragraph: '기존의 일률적인 교재와 평가 방식은 학습자의 동기를 높이는 데 효과적이다.', correctAnswer: false, explanation: '기존의 일률적인 교재와 평가 방식은 개별 학습자의 흥미와 수준을 고려하지 않아 학습 동기를 저하시킬 수 있습니다.'),
// //   OxQuestion(paragraph: '코코는 고양이다.', correctAnswer: false, explanation: '코코는 강아지입니다.'),
// // ];
// //
// // List<McqQuestion> mcqQuestions = [
// //   McqQuestion(
// //     paragraph: '맞춤형 읽기 도구의 특징으로 가장 적합한 설명은?',
// //     options: ['학습자의 흥미와 수준을 반영한다.', '단순한 교재 제공에 그친다.', '실시간 피드백을 제공하지 않는다.','일률적인 교재를 기반으로 한다.'],
// //     correctAnswerIndex: 0,
// //     explanation: '맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.',
// //   ),
// //   McqQuestion(
// //     paragraph: '코코는 어떤 동물인가요?',
// //     options: ['고양이', '강아지', '토끼'],
// //     correctAnswerIndex: 1,
// //     explanation: '맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.',
// //   ),
// // ];Questions