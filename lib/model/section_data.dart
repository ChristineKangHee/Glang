import 'stage_data.dart';

/// 각 스테이지의 데이터를 관리하는 모델 클래스
class StageData {
  final String subdetailTitle;  // 스테이지 제목
  final String totalTime;       // 예상 소요 시간
  int achievement;  // 진행도 (0~100%)
  final String difficultyLevel; // 난이도
  final String textContents;    // 스테이지 설명
  final List<String> missions;  // 학습 미션 리스트
  final List<String> effects;   // 학습 효과 리스트
  String status;          // 스테이지 상태 (예: 완료, 진행중, 시작 전)

  bool beforeReadingCompleted;  // 읽기 전 활동 완료 여부
  bool duringReadingCompleted;  // 읽기 중 활동 완료 여부
  bool afterReadingCompleted;   // 읽기 후 활동 완료 여부

  StageData({
    required this.subdetailTitle,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.textContents,
    required this.missions,
    required this.effects,
    required this.status,
    this.beforeReadingCompleted = false,
    this.duringReadingCompleted = false,
    this.afterReadingCompleted = false,
  });

  // Firebase 연동을 위해 fromJson/toJson 메서드 추가도 고려할 수 있음.
  // factory StageData.fromJson(Map<String, dynamic> json) {
  //   return StageData(
  //     subdetailTitle: json['subdetailTitle'] as String,
  //     totalTime: json['totalTime'] as String,
  //     achievement: json['achievement'] as String,
  //     difficultyLevel: json['difficultyLevel'] as String,
  //     textContents: json['textContents'] as String,
  //     missions: List<String>.from(json['missions'] as List),
  //     effects: List<String>.from(json['effects'] as List),
  //     status: json['status'] as String,
  //   );
  // }
  /// 활동 완료 시 진행도 업데이트 및 상태 변경
  void completeActivity(String activityType) {
    if (activityType == "beforeReading" && !beforeReadingCompleted) {
      beforeReadingCompleted = true;
      achievement += 30;
    } else if (activityType == "duringReading" && !duringReadingCompleted) {
      duringReadingCompleted = true;
      achievement += 30;
    } else if (activityType == "afterReading" && !afterReadingCompleted) {
      afterReadingCompleted = true;
      achievement += 40;
      status = "completed";  // 스테이지 완료
    }
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'subdetailTitle': subdetailTitle,
  //     'totalTime': totalTime,
  //     'achievement': achievement,
  //     'difficultyLevel': difficultyLevel,
  //     'textContents': textContents,
  //     'missions': missions,
  //     'effects': effects,
  //     'status': status,
  //   };
  // }
}

/// 각 코스(섹션)의 데이터를 관리하는 모델 클래스
class SectionData {
  final int section;             // 섹션 번호 (예: 1, 2, 3)
  final String title;            // 코스 제목 (예: 코스1, 코스2)
  final String sectionDetail;    // 코스에 대한 설명
  final List<StageData> stages;  // 해당 코스의 스테이지 목록

  SectionData({
    required this.section,
    required this.title,
    required this.sectionDetail,
    required this.stages,
  });

  // Firebase 연동을 위한 fromJson/toJson 메서드도 추가할 수 있음.
  // factory SectionData.fromJson(Map<String, dynamic> json) {
  //   return SectionData(
  //     section: json['section'] as int,
  //     title: json['title'] as String,
  //     sectionDetail: json['sectionDetail'] as String,
  //     stages: (json['stages'] as List)
  //         .map((stageJson) => StageData.fromJson(stageJson as Map<String, dynamic>))
  //         .toList(),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'section': section,
  //     'title': title,
  //     'sectionDetail': sectionDetail,
  //     'stages': stages.map((stage) => stage.toJson()).toList(),
  //   };
  // }
}

/// 코스(섹션) 데이터 목록
final List<SectionData> sectionList = [
  SectionData(
    section: 1,
    title: '초급 코스',
    sectionDetail: '초급 학습을 위한 코스입니다.',
    stages: stageList.sublist(0, 2), // stageList에서 첫 번째, 두 번째 스테이지 사용
  ),
  SectionData(
    section: 2,
    title: '중급 코스',
    sectionDetail: '중급 학습을 위한 코스입니다.',
    stages: stageList.sublist(2, 3), // 세 번째 스테이지 사용
  ),
  SectionData(
    section: 3,
    title: '고급 코스',
    sectionDetail: '고급 학습을 위한 코스입니다.',
    stages: stageList.sublist(3, 4), // 네 번째 스테이지 사용
  ),
];
