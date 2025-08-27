import 'levelTest_quiz_data.dart';

class LevelTestStageData {
  final String id;
  final String title;
  final List<String> paragraphs;
  final List<LevelTestParagraph> quizzes;

  LevelTestStageData({
    required this.id,
    required this.title,
    required this.paragraphs,
    required this.quizzes,
  });
}
