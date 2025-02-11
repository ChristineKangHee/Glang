// ar_data.dart
class ArData {
  final List<int> features; // 예: [1, 2, 5, 9]
  /// 각 feature 번호(문자열)별 완료 여부를 저장하는 필드
  final Map<String, bool> featuresCompleted;
  /// feature별 세부 데이터 (필요시 사용)
  final Map<String, dynamic>? featureData;

  ArData({
    required this.features,
    required this.featuresCompleted,
    this.featureData,
  });

  factory ArData.fromJson(Map<String, dynamic> json) {
    // features 목록이 없으면 빈 리스트, 있으면 그대로
    final features = List<int>.from(json['features'] ?? []);
    // featuresCompleted가 없으면, features 목록의 각 번호에 대해 false로 초기화
    final Map<String, bool> featuresCompleted = json['featuresCompleted'] == null
        ? { for (var f in features) f.toString() : false }
        : Map<String, bool>.from(json['featuresCompleted']);
    return ArData(
      features: features,
      featuresCompleted: featuresCompleted,
      featureData: json['featureData'] == null
          ? null
          : Map<String, dynamic>.from(json['featureData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features': features,
      'featuresCompleted': featuresCompleted,
      'featureData': featureData,
    };
  }
}
