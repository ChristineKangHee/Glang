// lib/services/progress_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';

class ProgressSeeder {
  /// 마스터(stages/{stageId})의 필드를 "그대로" 복사하여
  /// users/{uid}/progress/root/sections/{stageId} 문서의 최상위에 넣는다.
  /// overrideProgressFields=true면 상태/진행 관련 필드를 원하는 값으로 덮어씀.
  static Future<void> seedUserProgressAfterTutorial(
      String uid, {
        bool overrideProgressFields = false, // 기본: 마스터 값 그대로 사용
      }) async {
    if (uid.isEmpty) throw ArgumentError('uid is empty');

    final db = FirebaseFirestore.instance;

    // 1) 마스터 스테이지 원본(raw) 가져오기 (타입 변환 없이 그대로)
    final masterSnap = await db
        .collection('stages')
        .get(const GetOptions(source: Source.serverAndCache));

    // 2) 유저/컬렉션 레퍼런스
    final userDoc = db.collection('users').doc(uid);
    final progressCol = db.collection(FsPaths.userProgressSections(uid)); // users/{uid}/progress/root/sections

    final batch = db.batch();

    // 3) 유저 문서 보증
    batch.set(
      userDoc,
      {'createdAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    // 4) 각 스테이지별로 복사
    for (final doc in masterSnap.docs) {
      final stageId = doc.id;
      final master = Map<String, dynamic>.from(doc.data());

      // (선택) 유저 진행용 필드를 덮어쓸지 여부
      final progressDefaults = <String, dynamic>{
        'stageId': stageId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (overrideProgressFields) {
        progressDefaults.addAll({
          'status': 'locked',
          'achievement': 0,
          'activityCompleted': const {
            'beforeReading': false,
            'duringReading': false,
            'afterReading': false,
          },
        });
      }

      // 🔑 중요: "마스터 필드 먼저 → 진행 필드 나중" 순서로 스프레드해야
      // 진행 필드가 최종 값으로 덮어씌워짐(원하면).
      final payload = <String, dynamic>{
        ...master,          // 마스터 그대로
        ...progressDefaults // stageId/createdAt (+옵션 덮어쓰기)
      };

      batch.set(progressCol.doc(stageId), payload, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
