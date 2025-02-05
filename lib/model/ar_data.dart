class ArData {
  final List<int> features; // [1, 2, 5, 9] 이런 식
  // feature별 세부 데이터는 optional
  final Map<String, dynamic>? featureData;
  // 혹은 feature마다 별도 클래스를 정의할 수도 있음 (e.g. feature2Data, feature9Data...)

  ArData({
    required this.features,
    this.featureData,
  });

  factory ArData.fromJson(Map<String, dynamic> json) {
    return ArData(
      features: List<int>.from(json['features'] ?? []),
      featureData: json['featureData'] == null
          ? null
          : Map<String, dynamic>.from(json['featureData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features': features,
      'featureData': featureData,
    };
  }
}
