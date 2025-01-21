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

List<OxQuestion> oxQuestions = [
  OxQuestion(paragraph: '코코는 강아지다.', correctAnswer: true, explanation: '코코는 강아지입니다.'),
  OxQuestion(paragraph: '코코는 고양이다.', correctAnswer: false, explanation: '코코는 강아지입니다.'),
];

List<McqQuestion> mcqQuestions = [
  McqQuestion(
    paragraph: '코코는 어떤 동물인가요?',
    options: ['고양이', '강아지', '토끼'],
    correctAnswerIndex: 1,
    explanation: '코코는 강아지입니다.',
  ),
  McqQuestion(
    paragraph: '코코의 색깔은 무엇인가요?',
    options: ['흰색', '검은색', '갈색'],
    correctAnswerIndex: 0,
    explanation: '코코는 흰색 강아지입니다.',
  ),
];
