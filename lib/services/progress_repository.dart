// lib/services/progress_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';

class ProgressRepository {
  ProgressRepository._();
  static final instance = ProgressRepository._();

  final _db = FirebaseFirestore.instance;

  /// 진행 문서 읽기(단건)
  Future<Map<String, dynamic>?> getStageProgressOnce({
    required String uid,
    required String stageId,
  }) async {
    final doc = await _db
        .doc('${FsPaths.userProgressSections(uid)}/$stageId')
        .get(const GetOptions(source: Source.serverAndCache));
    return doc.data();
  }

  /// 진행 문서 스트림(단건)
  Stream<Map<String, dynamic>?> watchStageProgress({
    required String uid,
    required String stageId,
  }) {
    return _db
        .doc('${FsPaths.userProgressSections(uid)}/$stageId')
        .snapshots()
        .map((d) => d.data());
  }

  /// 진행 문서 스트림(모든 stage)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchAllStageProgress({
    required String uid,
  }) {
    return _db
        .collection(FsPaths.userProgressSections(uid))
        .snapshots()
        .map((q) => q.docs);
  }

  /// 진행 업데이트(merge)
  Future<void> setStageProgress({
    required String uid,
    required String stageId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .doc('${FsPaths.userProgressSections(uid)}/$stageId')
        .set(
      {
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
