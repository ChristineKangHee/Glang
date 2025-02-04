import 'package:cloud_firestore/cloud_firestore.dart';
import 'section_data.dart'; // SectionData, StageData 등

/// Firestore에서 현재 유저의 모든 스테이지 문서를 불러와서 List<StageData>로 변환
Future<List<StageData>> loadStagesFromFirestore(String userId) async {
  final progressRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('progress');

  final querySnapshot = await progressRef.get();

  // 🔹 만약 아무 문서도 없다면, 기본 스테이지 몇 개를 만들어 Firestore에 저장
  if (querySnapshot.docs.isEmpty) {
    await _createDefaultStages(progressRef);
    // 기본 스테이지 생성 후, 다시 데이터를 불러옵니다.
    final updatedSnapshot = await progressRef.get();
    return updatedSnapshot.docs.map((doc) {
      return StageData.fromJson(doc.id, doc.data());
    }).toList();
  }

  // 🔹 문서가 있다면 그대로 변환
  return querySnapshot.docs.map((doc) {
    return StageData.fromJson(doc.id, doc.data());
  }).toList();
}

/// 초기 상태(처음 앱에 들어왔을 때) Firestore에 기본 스테이지 문서를 만드는 함수
Future<void> _createDefaultStages(CollectionReference progressRef) async {
  // 원하는 만큼 기본 스테이지 생성
  final defaultStages = [
    StageData(
      stageId: "stage_001",
      subdetailTitle: "읽기 도구의 필요성",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.inProgress, // 첫 스테이지만 시작 가능
      difficultyLevel: "쉬움",
      textContents: "읽기 도구가 왜 필요한지 알아봅니다.",
      missions: ["미션 1-1", "미션 1-2", "미션 1-3"],
      effects: ["집중력 향상", "읽기 속도 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
    ),
    StageData(
      stageId: "stage_002",
      subdetailTitle: "읽기 도구 사용법",
      totalTime: "20",
      achievement: 0,
      status: StageStatus.locked,  // 아직 잠김
      difficultyLevel: "쉬움",
      textContents: "읽기 도구의 사용법을 익힙니다.",
      missions: ["미션 2-1", "미션 2-2"],
      effects: ["이해력 향상", "읽기 효율 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
    ),
    StageData(
      stageId: "stage_003",
      subdetailTitle: "심화 읽기 도구",
      totalTime: "25",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "조금 더 복잡한 도구 사용법.",
      missions: ["미션 3-1"],
      effects: ["읽기 속도 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
    ),
    StageData(
      stageId: "stage_004",
      subdetailTitle: "읽기 도구 실전 적용",
      totalTime: "40",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "어려움",
      textContents: "실전에서 도구를 제대로 활용해 봅시다.",
      missions: ["미션 4-1", "미션 4-2"],
      effects: ["이해력/속도 동시 향상"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
    ),
  ];

  // Firestore에 저장
  for (final stage in defaultStages) {
    await progressRef.doc(stage.stageId).set(stage.toJson());
  }
}

/// 특정 스테이지의 진행 상태를 업데이트하고, Firestore에도 반영하는 함수.
/// 예: "읽기 전 활동 완료" 버튼을 눌렀을 때 호출
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

  // 문서가 있는지 확인
  final snapshot = await docRef.get();
  if (!snapshot.exists) {
    // 문서가 없는 경우 처리. (에러, 또는 무시)
    return;
  }

  // 문서 → StageData
  final stage = StageData.fromJson(snapshot.id, snapshot.data()!);

  // 로컬 StageData 객체에서 활동 완료 처리
  stage.completeActivity(activityType);

  // Firestore 업데이트
  await docRef.update(stage.toJson());
}
