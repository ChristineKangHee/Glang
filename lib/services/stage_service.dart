// lib/services/stage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/stage_master.dart';

class StageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _stages = FirebaseFirestore.instance.collection('stages');

  /// 새 스테이지 정의 생성
  Future<String> createStage(StageMaster stage) async {
    final docRef = await _stages.add(stage.toMap());
    return docRef.id;
  }

  /// 스테이지 단건 조회
  Future<StageMaster?> getStage(String stageId) async {
    final doc = await _stages.doc(stageId).get();
    if (!doc.exists) return null;
    return StageMaster.fromDoc(doc);
  }

  /// 모든 스테이지 정의 불러오기
  Future<List<StageMaster>> getAllStages() async {
    final snap = await _stages.get();
    return snap.docs.map((d) => StageMaster.fromDoc(d)).toList();
  }

  /// 스테이지 정의 업데이트
  Future<void> updateStage(StageMaster stage) async {
    await _stages.doc(stage.id).update(stage.toMap());
  }

  /// 스테이지 정의 삭제
  Future<void> deleteStage(String stageId) async {
    await _stages.doc(stageId).delete();
  }
}
