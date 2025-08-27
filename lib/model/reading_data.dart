/// File: lib/model/reading_data.dart
/// Purpose: 읽기 중(During-Reading) 활동 데이터 (본문/MCQ/OX, 다국어 스키마 적용)
/// CHANGED:
///  - textSegments: List<String> → LocalizedList (Map/List 모두 허용)
///  - MultipleChoiceQuiz.question/explanation: String → LocalizedText
///  - MultipleChoiceQuiz.choices: List<String> → LocalizedList (Map/List 모두 허용)
///  - OXQuiz.question/explanation: String → LocalizedText
///  - JSON 컨버터에 구 스키마(단일 언어/단일 객체) 폴백 처리 추가

import 'package:flutter/foundation.dart';
import 'localized_types.dart';

@immutable
class ReadingData {
  final String coverImageUrl;
  final LocalizedList textSegments;                 // ko/en 리스트
  final List<MultipleChoiceQuiz> multipleChoice;    // 리스트/단일 객체 모두 허용
  final List<OXQuiz> oxQuiz;                        // 리스트/단일 객체 모두 허용

  const ReadingData({
    this.coverImageUrl = '',
    this.textSegments = const LocalizedList(),
    this.multipleChoice = const [],
    this.oxQuiz = const [],
  });

  factory ReadingData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReadingData();

    // textSegments: Map 또는 List 허용
    final LocalizedList segments = _parseLocalizedList(json['textSegments']);

    // multipleChoice: List 또는 단일 Map 허용
    final List<MultipleChoiceQuiz> mcList = _parseListOrSingle<MultipleChoiceQuiz>(
      json['multipleChoice'],
          (e) => MultipleChoiceQuiz.fromJson(_asMap(e)),
    );

    // oxQuiz: List 또는 단일 Map 허용
    final List<OXQuiz> oxList = _parseListOrSingle<OXQuiz>(
      json['oxQuiz'],
          (e) => OXQuiz.fromJson(_asMap(e)),
    );

    return ReadingData(
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      textSegments: segments,
      multipleChoice: mcList,
      oxQuiz: oxList,
    );
  }

  Map<String, dynamic> toJson() => {
    'coverImageUrl': coverImageUrl,
    'textSegments': textSegments.toJson(),
    'multipleChoice': multipleChoice.map((e) => e.toJson()).toList(),
    'oxQuiz': oxQuiz.map((e) => e.toJson()).toList(),
  };

  ReadingData copyWith({
    String? coverImageUrl,
    LocalizedList? textSegments,
    List<MultipleChoiceQuiz>? multipleChoice,
    List<OXQuiz>? oxQuiz,
  }) =>
      ReadingData(
        coverImageUrl: coverImageUrl ?? this.coverImageUrl,
        textSegments: textSegments ?? this.textSegments,
        multipleChoice: multipleChoice ?? this.multipleChoice,
        oxQuiz: oxQuiz ?? this.oxQuiz,
      );
}

@immutable
class MultipleChoiceQuiz {
  final LocalizedText question;               // 다국어
  final LocalizedList choices;                // 다국어 리스트
  final int correctIndex;                     // 정답 인덱스 (A→0, B→1 폴백 지원)
  final LocalizedText explanation;            // 다국어

  const MultipleChoiceQuiz({
    this.question = const LocalizedText(),
    this.choices = const LocalizedList(),
    this.correctIndex = 0,
    this.explanation = const LocalizedText(),
  });

  factory MultipleChoiceQuiz.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MultipleChoiceQuiz();

    final LocalizedList parsedChoices = _parseLocalizedList(json['choices']);
    final int idx = _parseCorrectIndex(
      rawIndex: json['correctIndex'],
      rawAnswer: json['correctAnswer'],
    );

    return MultipleChoiceQuiz(
      question: LocalizedText.fromJson(json['question']),
      choices: parsedChoices,
      correctIndex: idx,
      explanation: LocalizedText.fromJson(json['explanation']),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question.toJson(),
    'choices': choices.toJson(),
    'correctIndex': correctIndex,
    'explanation': explanation.toJson(),
  };

  MultipleChoiceQuiz copyWith({
    LocalizedText? question,
    LocalizedList? choices,
    int? correctIndex,
    LocalizedText? explanation,
  }) =>
      MultipleChoiceQuiz(
        question: question ?? this.question,
        choices: choices ?? this.choices,
        correctIndex: correctIndex ?? this.correctIndex,
        explanation: explanation ?? this.explanation,
      );
}

@immutable
class OXQuiz {
  final LocalizedText question;              // 다국어
  final bool correctAnswer;
  final LocalizedText explanation;           // 다국어

  const OXQuiz({
    this.question = const LocalizedText(),
    this.correctAnswer = false,
    this.explanation = const LocalizedText(),
  });

  factory OXQuiz.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OXQuiz();
    return OXQuiz(
      question: LocalizedText.fromJson(json['question']),
      correctAnswer: _parseBool(json['correctAnswer']),
      explanation: LocalizedText.fromJson(json['explanation']),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question.toJson(),
    'correctAnswer': correctAnswer,
    'explanation': explanation.toJson(),
  };

  OXQuiz copyWith({
    LocalizedText? question,
    bool? correctAnswer,
    LocalizedText? explanation,
  }) =>
      OXQuiz(
        question: question ?? this.question,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        explanation: explanation ?? this.explanation,
      );
}

// ----------------- Helpers -----------------

/// ko/en 맵 또는 단일 리스트(List<String>) 모두 허용.
/// 단일 리스트면 ko에만 채워서 폴백.
LocalizedList _parseLocalizedList(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return LocalizedList.fromJson(raw);
  }
  if (raw is List) {
    final list = raw.map((e) => e.toString()).toList();
    return LocalizedList(ko: list, en: const []);
  }
  return const LocalizedList();
}

/// 값이 List면 각각 파싱, Map이면 단일 원소 리스트로 감싼다.
/// null이면 빈 리스트.
List<T> _parseListOrSingle<T>(dynamic raw, T Function(dynamic) parseOne) {
  if (raw == null) return <T>[];
  if (raw is List) {
    return raw.map((e) => parseOne(e)).toList();
  }
  // 단일 객체(Map 등) → 1개짜리 리스트로 폴백
  return <T>[parseOne(raw)];
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((k, value) => MapEntry(k.toString(), value));
  }
  return null;
}

/// correctIndex(숫자) 또는 correctAnswer(문자열 "A"/"B"/...) 지원.
/// 숫자 문자열도 안전하게 파싱.
int _parseCorrectIndex({dynamic rawIndex, dynamic rawAnswer}) {
  // 1) 인덱스가 숫자/숫자문자열이면 우선 사용
  if (rawIndex is int) return rawIndex;
  final idxTry = int.tryParse(rawIndex?.toString() ?? '');
  if (idxTry != null) return idxTry;

  // 2) 정답문자(A/B/C/...) → 0/1/2/...
  final ans = (rawAnswer ?? '').toString().trim();
  if (ans.isNotEmpty) {
    final upper = ans.toUpperCase();
    // 예: "B" -> 1
    final code = upper.codeUnitAt(0);
    final aCode = 'A'.codeUnitAt(0);
    final zCode = 'Z'.codeUnitAt(0);
    if (code >= aCode && code <= zCode) {
      return code - aCode;
    }
    // 혹시 "2" 같은 숫자문자열이면 그것도 허용
    final fromNum = int.tryParse(upper);
    if (fromNum != null) return fromNum;
  }

  return 0;
}

bool _parseBool(dynamic v) {
  if (v is bool) return v;
  if (v is String) {
    final s = v.toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes' || s == 'y';
  }
  if (v is num) return v != 0;
  return false;
}
