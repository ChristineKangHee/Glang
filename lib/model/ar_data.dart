/// File: ar_data.dart
/// Purpose: 학습 후 활동의 데이터 구조를 정의하고, JSON 변환을 지원하는 모델 클래스
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

/*
  Comment by 민준
  - 학습 후 활동의 데이터 구조를 정의하는 모델입니다.
  - BR, Reading 활동에 비해서 데이터 형식이 자유롭습니다.
*/

/// **ArData 클래스**
/// - 학습 후 활동(After Reading)의 데이터 구조를 정의하는 모델.
/// - JSON 데이터를 변환하여 Firestore 등과 연동할 수 있도록 지원.
class ArData {
  /// **features**: 학습 후 활동의 기능(feature) 번호 목록.
  /// - 예시: `[1, 2, 5, 9]`
  final List<int> features;

  /// **featuresCompleted**: 각 feature 번호의 완료 여부를 저장하는 맵.
  /// - 키: feature 번호 (문자열 형식)
  /// - 값: 해당 feature가 완료되었는지 여부 (true/false)
  /// - 예시: `{ "1": true, "2": false, "5": true }`
  final Map<String, bool> featuresCompleted;

  /// **featureData**: feature별 세부 데이터 (선택적).
  /// - 필요할 경우 특정 feature에 대한 추가 정보를 저장하는 용도로 사용.
  /// - 예시: `{ "1": { "score": 90 }, "2": { "hintsUsed": 3 } }`
  final Map<String, dynamic>? featureData;

  /// **ArData 생성자**
  /// - 필수 값: `features`, `featuresCompleted`
  /// - 선택 값: `featureData`
  ArData({
    required this.features,
    required this.featuresCompleted,
    this.featureData,
  });

  /// **JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자**
  /// - Firestore 또는 API에서 받은 JSON 데이터를 `ArData` 객체로 변환.
  factory ArData.fromJson(Map<String, dynamic> json) {
    // 'features' 필드가 없으면 빈 리스트, 있으면 리스트 변환
    final features = List<int>.from(json['features'] ?? []);

    // 'featuresCompleted' 필드가 없으면 기본적으로 false로 초기화
    final Map<String, bool> featuresCompleted = json['featuresCompleted'] == null
        ? { for (var f in features) f.toString() : false } // features 목록의 각 번호를 false로 설정
        : Map<String, bool>.from(json['featuresCompleted']); // JSON 데이터에서 변환

    return ArData(
      features: features,
      featuresCompleted: featuresCompleted,
      featureData: json['featureData'] == null
          ? null
          : Map<String, dynamic>.from(json['featureData']), // JSON에서 featureData 변환
    );
  }

  /// **Dart 객체를 JSON 형식으로 변환하는 메서드**
  /// - Firestore 또는 API로 데이터를 저장할 때 사용.
  Map<String, dynamic> toJson() {
    return {
      'features': features, // features 리스트 변환
      'featuresCompleted': featuresCompleted, // featuresCompleted 맵 변환
      'featureData': featureData, // featureData 맵 변환 (null 가능)
    };
  }
}
