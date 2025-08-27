/// File: lib/model/ar_data.dart
/// Purpose: 학습 후(After-Reading) 활동 데이터 (다국어 스키마 적용)
/// CHANGED:
///  - features: List<String> → LocalizedList
///  - featuresCompleted(Map<String,bool>) 유지
///  - featureData(Map<String,dynamic>) 유지

import 'package:flutter/foundation.dart';
import 'localized_types.dart';

@immutable
class ArData {
  final LocalizedList features;                       // CHANGED
  final Map<String, bool> featuresCompleted;
  final Map<String, dynamic>? featureData;

  const ArData({
    this.features = const LocalizedList(),
    this.featuresCompleted = const {},
    this.featureData,
  });

  factory ArData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ArData();
    return ArData(
      features: LocalizedList.fromJson(json['features']),
      featuresCompleted: Map<String, bool>.from(json['featuresCompleted'] ?? const {}),
      featureData: json['featureData'] == null ? null : Map<String, dynamic>.from(json['featureData']),
    );
  }

  Map<String, dynamic> toJson() => {
    'features': features.toJson(),
    'featuresCompleted': featuresCompleted,
    'featureData': featureData,
  };

  ArData copyWith({
    LocalizedList? features,
    Map<String, bool>? featuresCompleted,
    Map<String, dynamic>? featureData,
  }) =>
      ArData(
        features: features ?? this.features,
        featuresCompleted: featuresCompleted ?? this.featuresCompleted,
        featureData: featureData ?? this.featureData,
      );
}
