//reading_data.dart
class ReadingData {
  final String coverImageUrl;        // 표지 사진 (BR과 같다면 중복일 수도 있지만, 분리 가능)
  final List<String> textSegments;   // 글 내용을 3분할
  final MultipleChoiceQuiz multipleChoice;
  final OXQuiz oxQuiz;

  ReadingData({
    required this.coverImageUrl,
    required this.textSegments,
    required this.multipleChoice,
    required this.oxQuiz,
  });

  factory ReadingData.fromJson(Map<String, dynamic> json) {
    return ReadingData(
      coverImageUrl: json['coverImageUrl'] ?? '',
      textSegments: List<String>.from(json['textSegments'] ?? []),
      multipleChoice: MultipleChoiceQuiz.fromJson(json['multipleChoice'] ?? {}),
      oxQuiz: OXQuiz.fromJson(json['oxQuiz'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coverImageUrl': coverImageUrl,
      'textSegments': textSegments,
      'multipleChoice': multipleChoice.toJson(),
      'oxQuiz': oxQuiz.toJson(),
    };
  }
}

class MultipleChoiceQuiz {
  final String question;
  final String correctAnswer;
  final List<String> choices;
  final String explanation;

  MultipleChoiceQuiz({
    required this.question,
    required this.correctAnswer,
    required this.choices,
    required this.explanation,
  });

  factory MultipleChoiceQuiz.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuiz(
      question: json['question'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'correctAnswer': correctAnswer,
    'choices': choices,
    'explanation': explanation,
  };
}

class OXQuiz {
  final String question;
  final bool correctAnswer;
  final String explanation;
  OXQuiz({
    required this.question,
    required this.correctAnswer,
    required this.explanation
  });

  factory OXQuiz.fromJson(Map<String, dynamic> json) {
    return OXQuiz(
      question: json['question'] ?? '',
      correctAnswer: json['correctAnswer'] == true,
      // Firestore에서 bool 형태로 저장하거나, 'O'/'X'로 저장한다면 변환 로직 추가
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
  };
}
