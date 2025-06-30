// lib/models/section_master.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SectionMaster {
  final String id;
  final String title;
  final String detail;
  final List<String> stageIds;

  SectionMaster({
    required this.id,
    required this.title,
    required this.detail,
    required this.stageIds,
  });

  factory SectionMaster.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SectionMaster(
      id: doc.id,
      title: data['title'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      stageIds: List<String>.from(data['stageIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'detail': detail,
    'stageIds': stageIds,
  };
}
