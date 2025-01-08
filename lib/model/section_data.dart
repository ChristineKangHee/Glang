class SectionData {
  final int section;
  final String title;
  final String sectionDetail;
  final List<String> subdetailTitle;
  final List<String> totalTime;
  final List<String> achievement;
  final List<String> difficultyLevel;
  final List<String> textContents;
  final List<String> imageUrls;
  final List<List<String>> missions;
  final List<List<String>> effects;
  final List<String> status;

  SectionData({
    required this.section,
    required this.title,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.sectionDetail,
    required this.subdetailTitle,
    required this.textContents,
    required this.imageUrls,
    required this.missions,
    required this.effects,
    required this.status,
  });
}