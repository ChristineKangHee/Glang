class SectionData {
  final int section; // 섹션 1 2 3 숫자로 구분. course에서 사용
  final String title; // 코스1, 코스2
  final String sectionDetail; // 초급코스 설명 내용
  final List<String> subdetailTitle; // subdetail 페이지에서 하나의 스테이지의 제목
  final List<String> totalTime; // 스테이지 완료 예상 시간
  final List<String> achievement; // 진행률
  final List<String> difficultyLevel; // 스테이지 난이도
  final List<String> textContents; // 스테이지의 설명
  // final List<String> imageUrls; // 없어도 된다. 삭제.
  final List<List<String>> missions; // 학습 미션
  final List<List<String>> effects; // 학습 효과
  final List<String> status; // 완료, 진행중, 시작 전 상태

  SectionData({
    required this.section,
    required this.title,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.sectionDetail,
    required this.subdetailTitle,
    required this.textContents,
    // required this.imageUrls,
    required this.missions,
    required this.effects,
    required this.status,
  });
}