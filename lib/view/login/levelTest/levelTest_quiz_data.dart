/// File: levelTest_quiz_data.dart
/// Purpose: 레벨 테스트용 퀴즈 모델 및 샘플 데이터 정의
/// Author: 강희
/// Created: 2024-01-19
/// Last Modified: 2024-07-20 by 강희

/// OX 퀴즈 모델
class LevelTestOxQuestion {
  final String paragraph;
  final bool correctAnswer;

  LevelTestOxQuestion({
    required this.paragraph,
    required this.correctAnswer,
  });
}

/// 객관식 퀴즈 모델
class LevelTestMcqQuestion {
  final String paragraph;
  final List<String> options;
  final int correctAnswerIndex;

  LevelTestMcqQuestion({
    required this.paragraph,
    required this.options,
    required this.correctAnswerIndex,
  });
}

/// 문단 주제 추론 퀴즈 모델 (단답형 주제 추론용)
class LevelTestParagraph {
  final String question;
  final List<String> options;
  final int correctIndex;

  LevelTestParagraph({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// ✅ 샘플 데이터 (Provider 또는 위젯에서 바로 사용 가능)

final LevelTestMcqQuestion mcqQuiz = LevelTestMcqQuestion(
  paragraph: '지금 당신이 읽고 있는 문장은 레벨테스트의 일부입니다.',
  options: ['이해하기 어렵다', '글의 구조가 복잡하다', '중요한 메시지가 있다', '문장이 너무 짧다'],
  correctAnswerIndex: 2,
);

final LevelTestOxQuestion oxQuiz = LevelTestOxQuestion(
  paragraph: '이 문단은 문제를 풀기 위한 분석 대상입니다.',
  correctAnswer: true,
);
