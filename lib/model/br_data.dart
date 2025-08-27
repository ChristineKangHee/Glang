/// File: lib/model/br_data.dart
/// Purpose: 읽기 전(Pre-Reading) 활동 데이터 모델 (다국어 스키마 적용)
/// CHANGED: `keywords: List<String>` → `LocalizedList`
///          JSON 직렬화/역직렬화에서 구 스키마(단일 리스트)도 안전 폴백으로 수용

import 'package:flutter/foundation.dart';
import 'localized_types.dart';

@immutable
class BrData {
  final String coverImageUrl;       // 표지 이미지 URL
  final LocalizedList keywords;     // CHANGED: 다국어 리스트

  const BrData({
    this.coverImageUrl = '',
    this.keywords = const LocalizedList(),
  });

  factory BrData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BrData();
    return BrData(
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      keywords: LocalizedList.fromJson(json['keywords']),
    );
  }

  Map<String, dynamic> toJson() => {
    'coverImageUrl': coverImageUrl,
    'keywords': keywords.toJson(),
  };

  BrData copyWith({
    String? coverImageUrl,
    LocalizedList? keywords,
  }) =>
      BrData(
        coverImageUrl: coverImageUrl ?? this.coverImageUrl,
        keywords: keywords ?? this.keywords,
      );
}
