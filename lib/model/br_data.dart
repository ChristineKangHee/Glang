// br_data.dart

class BrData {
  final String coverImageUrl;       // 표지 사진
  final List<String> keywords;      // 표지 키워드 (3개)

  BrData({
    required this.coverImageUrl,
    required this.keywords,
  });

  factory BrData.fromJson(Map<String, dynamic> json) {
    return BrData(
      coverImageUrl: json['coverImageUrl'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coverImageUrl': coverImageUrl,
      'keywords': keywords,
    };
  }
}
