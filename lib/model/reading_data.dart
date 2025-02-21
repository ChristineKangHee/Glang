/// File: reading_data.dart
/// Purpose: 읽기 중(During-Reading) 활동 데이터를 관리하는 모델 클래스, 퀴즈 및 텍스트 세그먼트 포함
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

/*
  Comment by 민준
  - 읽기 중 활동의 데이터를 저장하는 모델.
  - 내부에 다지선다 퀴즈 모델, oxquiz 모델 두 개 더 존재.
 */

/// **ReadingData 클래스**
/// - "읽기 중(During-Reading)" 활동에서 사용되는 데이터 모델.
/// - 표지 이미지, 텍스트 세그먼트(본문 3분할), 객관식 퀴즈, OX 퀴즈 정보를 포함.
/// - Firestore 또는 API 데이터와 JSON 변환을 지원.
class ReadingData {
  /// **coverImageUrl**: 표지 이미지 URL
  /// - `BrData`(읽기 전 활동)와 동일한 이미지일 수도 있으나, 독립적으로 관리 가능.
  final String coverImageUrl;

  /// **textSegments**: 본문을 3개의 세그먼트로 나눈 리스트.
  /// - 예시: `["첫 번째 부분", "두 번째 부분", "세 번째 부분"]`
  final List<String> textSegments;

  /// **multipleChoice**: 객관식 퀴즈 객체.
  /// - `MultipleChoiceQuiz` 클래스 인스턴스로 관리.
  final MultipleChoiceQuiz multipleChoice;

  /// **oxQuiz**: OX 퀴즈 객체.
  /// - `OXQuiz` 클래스 인스턴스로 관리.
  final OXQuiz oxQuiz;

  /// **ReadingData 생성자**
  /// - `coverImageUrl`, `textSegments`, `multipleChoice`, `oxQuiz` 필수 값.
  ReadingData({
    required this.coverImageUrl,
    required this.textSegments,
    required this.multipleChoice,
    required this.oxQuiz,
  });

  /// **JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자**
  /// - Firestore 또는 API에서 받은 JSON 데이터를 `ReadingData` 객체로 변환.
  factory ReadingData.fromJson(Map<String, dynamic> json) {
    return ReadingData(
      /// 표지 이미지가 없을 경우 기본값 `""` 설정.
      coverImageUrl: json['coverImageUrl'] ?? '',

      /// 본문 텍스트 세그먼트가 없을 경우 빈 리스트로 초기화.
      textSegments: List<String>.from(json['textSegments'] ?? []),

      /// 객관식 퀴즈 데이터를 `MultipleChoiceQuiz` 객체로 변환.
      multipleChoice: MultipleChoiceQuiz.fromJson(json['multipleChoice'] ?? {}),

      /// OX 퀴즈 데이터를 `OXQuiz` 객체로 변환.
      oxQuiz: OXQuiz.fromJson(json['oxQuiz'] ?? {}),
    );
  }

  /// **Dart 객체를 JSON 형식으로 변환하는 메서드**
  /// - Firestore 또는 API로 데이터를 저장할 때 사용.
  Map<String, dynamic> toJson() {
    return {
      'coverImageUrl': coverImageUrl,
      'textSegments': textSegments,
      'multipleChoice': multipleChoice.toJson(),
      'oxQuiz': oxQuiz.toJson(),
    };
  }
}

/// **객관식 퀴즈(Multiple Choice Quiz) 모델 클래스**
/// - 질문(`question`), 정답(`correctAnswer`), 선택지(`choices`), 설명(`explanation`) 포함.
class MultipleChoiceQuiz {
  final String question;         // 문제 텍스트
  final String correctAnswer;    // 정답 (선택지 중 하나)
  final List<String> choices;    // 객관식 선택지 리스트
  final String explanation;      // 정답에 대한 설명

  /// **MultipleChoiceQuiz 생성자**
  MultipleChoiceQuiz({
    required this.question,
    required this.correctAnswer,
    required this.choices,
    required this.explanation,
  });

  /// **JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자**
  factory MultipleChoiceQuiz.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuiz(
      question: json['question'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }

  /// **Dart 객체를 JSON 형식으로 변환하는 메서드**
  Map<String, dynamic> toJson() => {
    'question': question,
    'correctAnswer': correctAnswer,
    'choices': choices,
    'explanation': explanation,
  };
}

/// **OX 퀴즈(OX Quiz) 모델 클래스**
/// - 질문(`question`), 정답(`correctAnswer`), 설명(`explanation`) 포함.
class OXQuiz {
  final String question;      // 문제 텍스트
  final bool correctAnswer;   // 정답 (true: O, false: X)
  final String explanation;   // 정답에 대한 설명

  /// **OXQuiz 생성자**
  OXQuiz({
    required this.question,
    required this.correctAnswer,
    required this.explanation,
  });

  /// **JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자**
  factory OXQuiz.fromJson(Map<String, dynamic> json) {
    return OXQuiz(
      question: json['question'] ?? '',
      correctAnswer: json['correctAnswer'] == true, // Firestore에서 `bool` 타입으로 변환
      explanation: json['explanation'] ?? '',
    );
  }

  /// **Dart 객체를 JSON 형식으로 변환하는 메서드**
  Map<String, dynamic> toJson() => {
    'question': question,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
  };
}
