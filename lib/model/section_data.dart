/// File: section_data.dart
/// Purpose: 학습 코스 및 스테이지 데이터를 관리하는 모델 클래스 정의
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

import 'package:readventure/model/reading_data.dart';

import 'ar_data.dart';
import 'br_data.dart';
import 'stage_data.dart';

enum StageStatus { locked, inProgress, completed }

class StageData {
  final String stageId;                // 스테이지 식별용 ID (ex: 'stage_001')
  final String subdetailTitle;         // 스테이지 제목
  final String totalTime;             // 예상 소요 시간
  int achievement;                    // 진행도 (0~100%)
  StageStatus status;                 // 스테이지 상태
  final String difficultyLevel;
  final String textContents;
  final List<String> missions;
  final List<String> effects;

  // 활동 완료 여부는 Map으로
  final Map<String, bool> activityCompleted;

  // **추가: 새로운 하위 모델**
  final BrData? brData;         // 읽기 전(BR) 데이터
  final ReadingData? readingData;   // 읽기 중(READING) 데이터
  final ArData? arData;         // 읽기 후(AR) 데이터

  StageData({
    required this.stageId,
    required this.subdetailTitle,
    required this.totalTime,
    required this.achievement,
    required this.status,
    required this.difficultyLevel,
    required this.textContents,
    required this.missions,
    required this.effects,
    required this.activityCompleted,
    this.brData,
    this.readingData,
    this.arData,
  });

  // Firestore → StageData
  factory StageData.fromJson(String stageId, Map<String, dynamic> json) {
    return StageData(
      stageId: stageId,
      subdetailTitle: json['subdetailTitle'] as String,
      totalTime: json['totalTime'] as String,
      achievement: json['achievement'] as int,
      status: _statusFromString(json['status'] as String),
      difficultyLevel: json['difficultyLevel'] as String,
      textContents: json['textContents'] as String,
      missions: List<String>.from(json['missions'] as List),
      effects: List<String>.from(json['effects'] as List),
      activityCompleted: Map<String, bool>.from(json['activityCompleted'] as Map),

      // 하위 모델은 존재하면 fromJson, 없으면 null
      brData: json['brData'] == null
          ? null
          : BrData.fromJson(json['brData']),
      readingData: json['readingData'] == null
          ? null
          : ReadingData.fromJson(json['readingData']),
      arData: json['arData'] == null
          ? null
          : ArData.fromJson(json['arData']),
    );
  }

  // StageData → Map
  Map<String, dynamic> toJson() {
    return {
      'subdetailTitle': subdetailTitle,
      'totalTime': totalTime,
      'achievement': achievement,
      'status': _statusToString(status),
      'difficultyLevel': difficultyLevel,
      'textContents': textContents,
      'missions': missions,
      'effects': effects,
      'activityCompleted': activityCompleted,

      // 하위 모델
      'brData': brData?.toJson(),
      'readingData': readingData?.toJson(),
      'arData': arData?.toJson(),
    };
  }

  // 상태 enum ↔ String 변환 헬퍼
  static StageStatus _statusFromString(String status) {
    switch (status) {
      case 'locked':
        return StageStatus.locked;
      case 'inProgress':
        return StageStatus.inProgress;
      case 'completed':
        return StageStatus.completed;
      default:
        return StageStatus.locked; // default
    }
  }

  static String _statusToString(StageStatus status) {
    switch (status) {
      case StageStatus.locked:
        return 'locked';
      case StageStatus.inProgress:
        return 'inProgress';
      case StageStatus.completed:
        return 'completed';
    }
  }

  // 활동 완료 시 진행도 업데이트 (예시)
  void completeActivity(String activityType) {
    if (activityCompleted[activityType] == false) {
      activityCompleted[activityType] = true;
      // TODO: 로직에 따라 어떤 percent를 더할지 결정
      if (activityType == 'beforeReading') {
        achievement += 20;
      } else if (activityType == 'duringReading') {
        achievement += 30;
      } else if (activityType == 'afterReading') {
        achievement += 50;
      }

      // 100% 초과 방지
      if (achievement > 100) {
        achievement = 100;
      }

      // 모든 활동이 완료되면 status 변경
      final allCompleted = activityCompleted.values.every((v) => v == true);
      if (allCompleted) {
        status = StageStatus.completed;
      } else {
        status = StageStatus.inProgress;
      }
    }
  }
  /// 새로운 메서드: AR 내 특정 feature의 완료 상태를 업데이트
  void updateArFeatureCompletion(int featureNumber, bool isCompleted) {
    if (arData != null) {
      arData!.featuresCompleted[featureNumber.toString()] = isCompleted;
    }
  }

}

/// 각 코스(섹션)의 데이터를 관리하는 모델 클래스
class SectionData {
  final int section; // 섹션 번호 (예: 1, 2, 3)
  final String title; // 코스 제목 (예: 코스1, 코스2)
  final String sectionDetail; // 코스에 대한 설명
  final List<StageData> stages; // 해당 코스의 스테이지 목록

  SectionData({
    required this.section,
    required this.title,
    required this.sectionDetail,
    required this.stages,
  });

  /// 코스(섹션) 데이터 목록
  /// 비동기 방식으로 스테이지 데이터를 가져와서 섹션 데이터를 생성

  static Future<List<SectionData>> loadSections(String userId) async {
    final stages = await loadStagesFromFirestore(userId);

    // 1) 간단 예시: 스테이지 순서대로 잘라서 섹션 1~3 만들기
    return [
      SectionData(
        section: 1,
        title: '코스1',
        sectionDetail: '짧은 글 읽기',
        stages: stages.sublist(0, 4), // 첫 번째 스테이지
      ),
      SectionData(
        section: 2,
        title: '코스2',
        sectionDetail: '중간 길이 글 읽기',
        stages: stages.sublist(4, 8), // 두 번째 스테이지
      ),
      SectionData(
        section: 3,
        title: '코스3',
        sectionDetail: '긴 글 읽기',
        stages: stages.sublist(8, 12),
      ),
    ];
  }
}
