// lib/model/localized_types.dart
// CHANGED: 새 다국어 지원 타입 정의 (LocalizedText/LocalizedList) 및 JSON 컨버터.
// - 문자열/리스트를 ko/en 이중 언어로 관리.
// - 기존 단일 스키마에서 넘어오는 경우를 대비해 fromJson에서 안전 폴백 처리.

import 'package:flutter/foundation.dart';

@immutable
class LocalizedText {
  final String ko;
  final String en;
  const LocalizedText({this.ko = '', this.en = ''});

  factory LocalizedText.fromJson(dynamic j) {
    if (j == null) return const LocalizedText();

    // 문자열 → ko로 승격
    if (j is String) {
      return LocalizedText(ko: j, en: '');
    }

    // Map<String, dynamic> 처리
    if (j is Map<String, dynamic>) {
      return LocalizedText(
        ko: (j['ko'] ?? '').toString(),
        en: (j['en'] ?? '').toString(),
      );
    }

    return const LocalizedText();
  }


  Map<String, dynamic> toJson() => {'ko': ko, 'en': en};

  LocalizedText copyWith({String? ko, String? en}) =>
      LocalizedText(ko: ko ?? this.ko, en: en ?? this.en);

  bool get isEmpty => ko.trim().isEmpty && en.trim().isEmpty;
}

@immutable
class LocalizedList {
  final List<String> ko;
  final List<String> en;

  const LocalizedList({
    this.ko = const [],
    this.en = const [],
  });

  // 관대한 파서: Map/List/String/숫자 모두 처리
  factory LocalizedList.fromJson(dynamic raw) {
    // 헬퍼: 어떤 값이 오든 "문자열 리스트"로
    List<String> _asStringList(dynamic v) {
      if (v == null) return const [];
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
      }
      // 단일 값(문자/숫자 등) -> 1개짜리 리스트
      final one = v.toString();
      return one.isEmpty ? const [] : <String>[one];
    }

    if (raw == null) {
      return const LocalizedList();
    }

    // 신 스키마: { ko: [...], en: [...] }
    if (raw is Map) {
      final ko = _asStringList(raw['ko']);
      final en = _asStringList(raw['en']);
      return LocalizedList(ko: ko, en: en);
    }

    // 구 스키마: 단일 언어 리스트 (문자/숫자 섞여 있어도 허용)
    if (raw is List) {
      return LocalizedList(ko: _asStringList(raw));
    }

    // 구 스키마: 단일 문자열/숫자
    return LocalizedList(ko: _asStringList(raw));
  }

  Map<String, dynamic> toJson() => {
    'ko': ko,
    'en': en,
  };

  LocalizedList copyWith({
    List<String>? ko,
    List<String>? en,
  }) =>
      LocalizedList(
        ko: ko ?? this.ko,
        en: en ?? this.en,
      );
}
