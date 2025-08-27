// lib/viewmodel/section_provider.dart
// CHANGED: 섹션 마스터 의존 제거.
//          stages만으로 섹션 조립(LearningAssemblyService).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/section_data.dart';
import '../services/stage_repository.dart';
import '../services/learning_assembly_service.dart';

final sectionProvider = FutureProvider<List<SectionData>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const [];

  // (선택) 프리로드: 캐시 채워서 조립 속도 향상
  await StageRepository.instance.getAllStagesOnce();

  // stages만으로 섹션 조립
  return LearningAssemblyService.instance.buildPublicSections();
});
