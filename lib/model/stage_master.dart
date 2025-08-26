// lib/model/stage_master.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localized_types.dart';
import 'br_data.dart';
import 'reading_data.dart';
import 'ar_data.dart';

class StageMaster {
  final String id;
  final LocalizedText subdetailTitle;
  final String totalTime;
  final LocalizedList missions;
  final LocalizedList effects;
  final BrData brData;
  final ReadingData readingData;
  final ArData arData;

  // ✅ 추가된 필드
  final LocalizedText difficultyLevel;
  final LocalizedText textContents;

  StageMaster({
    required this.id,
    this.subdetailTitle = const LocalizedText(),
    this.totalTime = '',
    this.missions = const LocalizedList(),
    this.effects = const LocalizedList(),
    this.brData = const BrData(),
    this.readingData = const ReadingData(),
    this.arData = const ArData(),
    // ✅ 기본값
    this.difficultyLevel = const LocalizedText(),
    this.textContents = const LocalizedText(),
  });

  factory StageMaster.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});
    return StageMaster(
      id: doc.id,
      subdetailTitle: LocalizedText.fromJson(data['subdetailTitle'] as dynamic),
      totalTime: (data['totalTime'] ?? '').toString(),
      missions: LocalizedList.fromJson(data['missions']),
      effects: LocalizedList.fromJson(data['effects']),
      brData: BrData.fromJson(data['brData'] as Map<String, dynamic>?),
      readingData: ReadingData.fromJson(data['readingData'] as Map<String, dynamic>?),
      arData: ArData.fromJson(data['arData'] as Map<String, dynamic>?),

      // ✅ 추가된 필드 매핑 (널/형 변환 안전)
      difficultyLevel: LocalizedText.fromJson(data['difficultyLevel'] as dynamic),
      textContents: LocalizedText.fromJson(data['textContents'] as dynamic),
    );
  }

  Map<String, dynamic> toMap() => {
    'subdetailTitle': subdetailTitle.toJson(),
    'totalTime': totalTime,
    'missions': missions.toJson(),
    'effects': effects.toJson(),
    'brData': brData.toJson(),
    'readingData': readingData.toJson(),
    'arData': arData.toJson(),
    // ✅ 추가된 필드 직렬화
    'difficultyLevel': difficultyLevel.toJson(),
    'textContents': textContents.toJson(),
  };
}
