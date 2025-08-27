import 'levelTest_quiz_data.dart';
import 'level_test_stage_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final levelTestProvider = Provider<LevelTestStageData>((ref) {
  return LevelTestStageData(
    id: 'leveltest001',
    title: '레벨테스트',
    paragraphs: [
      '지금 당신이 읽고 있는 문장은 레벨테스트의 일부입니다.',
      '이 문단은 문제를 풀기 위한 분석 대상입니다.',
    ],
    quizzes: [
      LevelTestParagraph(
        question: '이 문단의 핵심 주제는 무엇인가요?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 2,
      ),
      LevelTestParagraph(
        question: '이 문단에서 알 수 없는 단어는 무엇인가요?',
        options: ['단어1', '단어2', '단어3', '단어4'],
        correctIndex: 1,
      ),
    ],
  );
});
