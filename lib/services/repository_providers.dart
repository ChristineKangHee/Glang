// lib/services/repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/learning_assembly_service.dart';
import '../services/firestore_paths.dart';
import '../model/section_data.dart';
import '../model/stage_data.dart';

final publicSectionsProvider = FutureProvider<List<SectionData>>((ref) async {
  // 1) 기본 섹션(마스터 기반) 조립
  final baseSections = await LearningAssemblyService.instance.buildPublicSections();

  // 로그인 안 됐으면 마스터만 보여주기(모두 locked일 수 있음)
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return baseSections;

  // 2) 진행 문서 일괄 로드
  final snap = await FirebaseFirestore.instance
      .collection(FsPaths.userProgressSections(uid)) // users/{uid}/progress/root/sections
      .get(const GetOptions(source: Source.serverAndCache));

  final progressById = { for (final d in snap.docs) d.id : d.data() };

  // 3) 진행 ↔ 섹션 병합
  StageStatus parseStatus(String? s) {
    switch (s) {
      case 'inProgress': return StageStatus.inProgress;
      case 'completed':  return StageStatus.completed;
      default:           return StageStatus.locked;
    }
  }

  Map<String, bool> acFrom(Map<String, dynamic> p) {
    final raw = p['activityCompleted'];
    final ac = (raw is Map<String, dynamic>) ? raw : const <String, dynamic>{};
    bool b(v) => v == true;
    return {
      'beforeReading': b(ac['beforeReading'] ?? p['beforeReading']),
      'duringReading': b(ac['duringReading'] ?? p['duringReading']),
      'afterReading' : b(ac['afterReading']  ?? p['afterReading']),
    };
  }

  int parseAchievement(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  return baseSections.map((sec) {
    final patchedStages = sec.stages.map((st) {
      final p = progressById[st.stageId];
      if (p == null) return st; // 진행 문서 없으면 마스터 그대로

      return st.copyWith(
        status:            parseStatus(p['status'] as String?),
        achievement:       parseAchievement(p['achievement']),
        activityCompleted: acFrom(p),
      );
    }).toList(growable: false);

    // SectionData에 copyWith가 없으면 새로 생성해서 반환하세요.
    return sec.copyWith(stages: patchedStages);
  }).toList(growable: false);
});
