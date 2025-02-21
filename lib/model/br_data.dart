/// File: br_data.dart
/// Purpose: 읽기 전(Pre-Reading) 활동 데이터를 관리하는 모델 클래스, 표지 이미지 및 키워드 포함
/// Author: 박민준
/// Created: 2025-01-07
/// Last Modified: 2025-01-07 by 박민준

/*
  Comment by 민준
  - 읽기 전 활동의 데이터를 저장하는 모델.
  - 현재는 읽기 전 활동이 표지 제목 맞추기 하나 뿐이라 해당 미션에 대한 데이터만 존재한다.
 */

/// **BrData 클래스**
/// - "읽기 전(Pre-Reading)" 활동의 데이터를 저장하는 모델.
/// - 표지 이미지(`coverImageUrl`)와 키워드(`keywords`)를 포함.
/// - Firestore 또는 API 데이터와 JSON 변환을 지원.
class BrData {
  /// **coverImageUrl**: 책 또는 학습 콘텐츠의 표지 이미지 URL.
  /// - Firestore에서 가져올 때 문자열로 저장됨.
  /// - 예시: `"https://example.com/image.jpg"`
  final String coverImageUrl;

  /// **keywords**: 표지에서 추출한 주요 키워드 목록.
  /// - 사용자가 표지를 보고 유추할 수 있는 핵심 단어.
  /// - 예시: `["모험", "판타지", "마법"]`
  final List<String> keywords;

  /// **BrData 생성자**
  /// - 표지 이미지 URL(`coverImageUrl`)과 키워드 리스트(`keywords`)를 필수 값으로 받음.
  BrData({
    required this.coverImageUrl,
    required this.keywords,
  });

  /// **JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자**
  /// - Firestore 또는 API에서 받은 JSON 데이터를 `BrData` 객체로 변환.
  factory BrData.fromJson(Map<String, dynamic> json) {
    return BrData(
      /// JSON에서 'coverImageUrl'이 없을 경우 기본값으로 빈 문자열(`''`)을 사용.
      coverImageUrl: json['coverImageUrl'] ?? '',

      /// JSON에서 'keywords'가 없으면 빈 리스트(`[]`)로 초기화.
      /// `List<String>.from(...)`을 사용하여 문자열 리스트로 변환.
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  /// **Dart 객체를 JSON 형식으로 변환하는 메서드**
  /// - Firestore 또는 API로 데이터를 저장할 때 사용.
  Map<String, dynamic> toJson() {
    return {
      'coverImageUrl': coverImageUrl, // 표지 이미지 URL 저장
      'keywords': keywords, // 키워드 리스트 저장
    };
  }
}
