// lib/models/stage_master.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StageMaster {
  final String id;
  final String subdetailTitle;
  final String totalTime;
  final List<String> missions;
  final List<String> effects;
  final Map<String, dynamic> brData;
  final Map<String, dynamic> readingData;
  final Map<String, dynamic> arData;

  StageMaster({
    required this.id,
    required this.subdetailTitle,
    required this.totalTime,
    required this.missions,
    required this.effects,
    required this.brData,
    required this.readingData,
    required this.arData,
  });

  factory StageMaster.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StageMaster(
      id: doc.id,
      subdetailTitle: data['subdetailTitle'] as String? ?? '',
      totalTime: data['totalTime'] as String? ?? '',
      missions: List<String>.from(data['missions'] ?? []),
      effects: List<String>.from(data['effects'] ?? []),
      brData: Map<String, dynamic>.from(data['brData'] ?? {}),
      readingData: Map<String, dynamic>.from(data['readingData'] ?? {}),
      arData: Map<String, dynamic>.from(data['arData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'subdetailTitle': subdetailTitle,
    'totalTime': totalTime,
    'missions': missions,
    'effects': effects,
    'brData': brData,
    'readingData': readingData,
    'arData': arData,
  };
}
