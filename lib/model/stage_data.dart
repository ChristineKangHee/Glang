// lib/model/stage_data.dart
// CHANGED: StageData를 단일 파일로 분리. 다국어 스키마 반영.
// - subdetailTitle/difficultyLevel/textContents: LocalizedText
// - missions/effects: LocalizedList
// - brData/readingData/arData: 강타입
// - stageId는 문서 ID로만 관리(필드 저장 금지)

import 'package:flutter/foundation.dart';
import 'localized_types.dart';
import 'br_data.dart';
import 'reading_data.dart';
import 'ar_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum StageStatus { locked, inProgress, completed }

@immutable
class StageData {
  final String stageId;                // 문서 ID
  final LocalizedText subdetailTitle;  // CHANGED
  final String totalTime;
  final int achievement;
  final StageStatus status;
  final LocalizedText difficultyLevel; // CHANGED
  final LocalizedText textContents;    // CHANGED
  final LocalizedList missions;        // CHANGED
  final LocalizedList effects;         // CHANGED
  final Map<String, bool> activityCompleted;
  final BrData? brData;
  final ReadingData? readingData;
  final ArData? arData;

  const StageData({
    required this.stageId,
    this.subdetailTitle = const LocalizedText(),
    this.totalTime = '',
    this.achievement = 0,
    this.status = StageStatus.locked,
    this.difficultyLevel = const LocalizedText(),
    this.textContents = const LocalizedText(),
    this.missions = const LocalizedList(),
    this.effects = const LocalizedList(),
    this.activityCompleted = const {
      'beforeReading': false,
      'duringReading': false,
      'afterReading': false,
    },
    this.brData,
    this.readingData,
    this.arData,
  });

  factory StageData.fromJson(String stageId, Map<String, dynamic> json) {
    return StageData(
      stageId: stageId,
      subdetailTitle: LocalizedText.fromJson(json['subdetailTitle'] as dynamic),
      totalTime: (json['totalTime'] ?? '').toString(),
      achievement: (json['achievement'] is int)
          ? json['achievement'] as int
          : int.tryParse((json['achievement'] ?? '0').toString()) ?? 0,
      status: _statusFromString((json['status'] ?? 'locked').toString()),
      difficultyLevel: LocalizedText.fromJson(json['difficultyLevel'] as dynamic),
      textContents: LocalizedText.fromJson(json['textContents'] as dynamic),
      missions: LocalizedList.fromJson(json['missions']),
      effects: LocalizedList.fromJson(json['effects']),
      activityCompleted: Map<String, bool>.from(json['activityCompleted'] ?? const {}),
      brData: json['brData'] == null ? null : BrData.fromJson(json['brData'] as Map<String, dynamic>?),
      readingData: json['readingData'] == null ? null : ReadingData.fromJson(json['readingData'] as Map<String, dynamic>?),
      arData: json['arData'] == null ? null : ArData.fromJson(json['arData'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    // stageId는 필드에 넣지 않음
    'subdetailTitle': subdetailTitle.toJson(),
    'totalTime': totalTime,
    'achievement': achievement,
    'status': _statusToString(status),
    'difficultyLevel': difficultyLevel.toJson(),
    'textContents': textContents.toJson(),
    'missions': missions.toJson(),
    'effects': effects.toJson(),
    'activityCompleted': activityCompleted,
    if (brData != null) 'brData': brData!.toJson(),
    if (readingData != null) 'readingData': readingData!.toJson(),
    if (arData != null) 'arData': arData!.toJson(),
  };

  static StageStatus _statusFromString(String s) {
    switch (s) {
      case 'inProgress':
        return StageStatus.inProgress;
      case 'completed':
        return StageStatus.completed;
      case 'locked':
      default:
        return StageStatus.locked;
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

  StageData copyWith({
    LocalizedText? subdetailTitle,
    String? totalTime,
    int? achievement,
    StageStatus? status,
    LocalizedText? difficultyLevel,
    LocalizedText? textContents,
    LocalizedList? missions,
    LocalizedList? effects,
    Map<String, bool>? activityCompleted,
    BrData? brData,
    ReadingData? readingData,
    ArData? arData,
  }) {
    return StageData(
      stageId: stageId,
      subdetailTitle: subdetailTitle ?? this.subdetailTitle,
      totalTime: totalTime ?? this.totalTime,
      achievement: achievement ?? this.achievement,
      status: status ?? this.status,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      textContents: textContents ?? this.textContents,
      missions: missions ?? this.missions,
      effects: effects ?? this.effects,
      activityCompleted: activityCompleted ?? this.activityCompleted,
      brData: brData ?? this.brData,
      readingData: readingData ?? this.readingData,
      arData: arData ?? this.arData,
    );
  }
}

/// 진행도 저장:
/// - activityType: 'beforeReading' | 'duringReading' | 'afterReading'
/// - activityCompleted 맵에서 해당 키를 true로 설정
/// - 3개가 모두 true면 status를 'completed'로 변경(아니면 기존값 유지)
Future<void> completeActivityForStage({
  required String userId,
  required String stageId,
  required String activityType,
}) async {
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('progress')
      .doc(stageId);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(docRef);
    if (!snap.exists) {
      // 문서 없으면 생성하거나 무시 (여기선 무시)
      return;
    }

    final data = Map<String, dynamic>.from(snap.data()!);

    // 현재 맵(or 기본 맵)
    final current = Map<String, bool>.from(data['activityCompleted'] ?? const {
      'beforeReading': false,
      'duringReading': false,
      'afterReading': false,
    });

    // 유효 키만 허용
    const validKeys = {'beforeReading', 'duringReading', 'afterReading'};
    if (!validKeys.contains(activityType)) {
      // 잘못된 키면 업데이트 안 함
      return;
    }

    // 이미 true면 조용히 반환 (멱등성)
    if (current[activityType] == true) {
      return;
    }

    // 해당 활동 완료
    current[activityType] = true;

    // 모두 완료인지 확인
    final allDone = validKeys.every((k) => current[k] == true);

    // 상태 결정: 모두 완료면 completed, 아니면 기존 유지 (없으면 inProgress)
    final prevStatus = (data['status'] ?? 'inProgress').toString();
    final nextStatus = allDone ? 'completed' : prevStatus;

    tx.update(docRef, {
      'activityCompleted': current,
      'status': nextStatus,
      // 원하면 타임스탬프도 기록 가능
      // 'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}
