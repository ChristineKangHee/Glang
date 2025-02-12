/// File: stage_data.dart
/// Purpose: Firestore에서 학습 스테이지 데이터를 불러오고 관리하는 기능을 제공
/// Author: 박민준
/// Created: 2025-02-04
/// Last Modified: 2025-02-05 by 박민준

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readventure/model/reading_data.dart';
import 'ar_data.dart';
import 'br_data.dart';
import 'section_data.dart'; // SectionData, StageData
import 'package:firebase_storage/firebase_storage.dart';

/// 특정 파일의 Firebase Storage 다운로드 URL을 가져오는 함수 현재는 covers 폴더
Future<String?> getCoverImageUrl(String fileName) async {
  try {
    final ref = FirebaseStorage.instance.ref().child('covers/$fileName');
    return await ref.getDownloadURL();
  } catch (e) {
    print('❌ Error getting download URL for $fileName: $e');
    return null;
  }
}

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
  final stageCoverUrl = await getCoverImageUrl("stage_001.png");
  print("[_createDefaultStages] stageCoverUrl: $stageCoverUrl");

  final defaultStages = [
    StageData(
      stageId: "stage_001",
      subdetailTitle: "환경 보호와 지속 가능한 미래",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.inProgress, // 첫 스테이지만 시작 가능
      difficultyLevel: "쉬움",
      textContents: "환경 보호와 지속 가능한 미래",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["집중력 향상", "읽기 속도 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      // 읽기 전(BR) 화면용 데이터
      brData: BrData (
        // Firebase Storage에서 다운받을 수 있는 URL을 바로 넣거나
        // 또는 일단 가짜로 두고 수정 가능
        coverImageUrl: stageCoverUrl ?? "",
        keywords: ["#읽기능력", "#맞춤형도구", "#피드백"],
      ),

      // 읽기 중(READING) 화면용 데이터
      readingData: ReadingData(
        coverImageUrl: stageCoverUrl ?? "",
        // 글 내용 3분할
        textSegments: [
          "환경 보호는 단지 자연을 지키는 것 이상의 중요성을 지닌다. 우리가 자원을 절약하고, 재활용을 장려하며, 탄소 배출을 줄이는 것이 우리의 미래를 위해 매우 중요하다. 기후 변화에 대응하기 위한 여러 기업과 국가의 노력들은 점차 긍정적인 변화를 만들어 가고 있지만, 여전히 많은 사람들이 일상 속에서 환경을 보호하는 실천을 외면하고 있다.",
          "특히, 개인의 작은 변화가 큰 영향을 미친다는 점에서, 정부의 정책 강화와 교육의 필요성이 더욱 강조된다. 또한, 기술 발전이 환경 보호와 지속 가능성을 지원하는 중요한 도전 과제가 될 것이다. ",
          "전 세계적으로 환경 친화적인 정책과 실천이 확산되고 있는 가운데, 우리는 계속해서 그 발전을 촉진할 책임이 있다.",
        ],

        // 사지선다 퀴즈
        multipleChoice: MultipleChoiceQuiz(
          question: "이 글의 핵심 주제는 무엇일까요?",
          correctAnswer: "B",
          choices: [
            "A. 기후 변화의 부정적인 영향",
            "B. 자연 자원의 절약과 재활용",
            "C. 정책을 통한 환경 보호",
            "D. 환경 보호의 경제적 이점",
          ],
          explanation: "환경 보호의 핵심은 자원의 절약과 재활용을 통한 지속 가능성 확보입니다."
        ),

        // OX 퀴즈
        oxQuiz: OXQuiz(
          question: "환경 보호가 기후 변화에 긍정적인 영향을 미친다고 주장하는 글의 내용에 맞는가?",
          correctAnswer: true,
          explanation: "글에서 환경 보호가 기후 변화에 긍정적인 영향을 미친다고 언급하고 있습니다.."
        ),
      ),

      // 읽기 후(AR) 화면용 데이터 - 지금은 간단히 예시만
      arData: ArData(
        // 예: 어떤 feature를 쓸지(여기서는 2번, 3번, 4번).
        features: [2, 3, 4],
        // 여기서 features 리스트의 각 번호에 대해 false 기본값 설정
        featuresCompleted: {
                  "2": false,
                  "3": false,
                  "4": false,
        },
        // featureData에 어떤 형태든 넣을 수 있음
        featureData: {
          "feature2ContentSummary": "내용 요약",
          "feature3Debate": "토론하기",
          "feature3DebateTopic": "환경 보호를 위한 강력한 정책이 더 필요하다",
          "feature4Diagram": {
            "title": "트리 구조에 알맞는 단어를 넣어주세요!",
            "subtitle": "<읽기의 중요성>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {
                    "id": "Child 1",
                    "children": [
                      {"id": "Grandchild 1"},
                      {"id": "Grandchild 2"}
                    ]
                  },
                  {
                    "id": "Child 2",
                    "children": [
                      {"id": "Grandchild 3"},
                      {"id": "Grandchild 4"}
                    ]
                  },
                  {
                    "id": "Child 3",
                    "children": [
                      {"id": "Grandchild 5"},
                      {"id": "Grandchild 6"}
                    ]
                  }
                ]
              }
            ],
            "correctAnswers": {
              "Root": "읽기 시스템",
              "Child 1": "문제점",
              "Grandchild 1": "교육 시스템",
              "Grandchild 2": "피드백 부족",
              "Child 2": "해결방안",
              "Grandchild 3": "맞춤형 읽기 도구",
              "Grandchild 4": "실시간 피드백",
              "Child 3": "기대효과",
              "Grandchild 5": "읽기 능력 향상",
              "Grandchild 6": "자기주도 학습 강화"
            },
            "wordList": [
              "읽기 시스템",
              "문제점",
              "교육 시스템",
              "피드백 부족",
              "해결방안",
              "맞춤형 읽기 도구",
              "실시간 피드백",
              "기대효과",
              "읽기 능력 향상",
              "자기주도 학습 강화"
            ]
          }
        },
      ),
    ),

    // ------ stage_002, stage_003, stage_004도 동일하게 작성 ------
    // 예시로 하나 더
    StageData(
      stageId: "stage_002",
      subdetailTitle: "읽기 도구 사용법",
      totalTime: "20",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "쉬움",
      textContents: "읽기 도구의 사용법을 익힙니다.",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["이해력 향상", "읽기 효율 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
      brData: BrData(
        coverImageUrl: stageCoverUrl ?? "",
        keywords: ["#사용법", "#연습하기", "#키워드3"],
      ),
      readingData: ReadingData(
        coverImageUrl: stageCoverUrl ?? "",
        textSegments: ["내용1", "내용2", "내용3"],
        multipleChoice: MultipleChoiceQuiz(
          question: "해당 도구의 장점이 아닌 것은?",
          correctAnswer: "A",
          choices: ["A. 실제로 단점", "B. 장점1", "C. 장점2", "D. 장점3"],
          explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",
        ),
        oxQuiz: OXQuiz(question: "이 도구는 무료이다.", correctAnswer: true, explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",),
      ),
      arData: ArData(
        features: [2, 3, 4],
        featuresCompleted: {
                  "2": false,
                  "3": false,
                  "4": false,
        },
        featureData: {
          "feature2ContentSummary": "내용 요약",
          "feature3Debate": "토론하기",
          "feature3DebateTopic": "환경 보호를 위한 강력한 정책이 더 필요하다",
          "feature4Diagram": "다이어그램",
        },
      ),
    ),

    StageData(
      stageId: "stage_003",
      subdetailTitle: "읽기 도구의 필요성",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.locked, // 첫 스테이지만 시작 가능
      difficultyLevel: "쉬움",
      textContents: "읽기 도구가 왜 필요한지 알아봅니다.",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["집중력 향상", "읽기 속도 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      // 읽기 전(BR) 화면용 데이터
      brData: BrData(
        // Firebase Storage에서 다운받을 수 있는 URL을 바로 넣거나
        // 또는 일단 가짜로 두고 수정 가능
        coverImageUrl: stageCoverUrl ?? "",
        keywords: ["#읽기능력", "#맞춤형도구", "#피드백"],
      ),

      // 읽기 중(READING) 화면용 데이터
      readingData: ReadingData(
        coverImageUrl: stageCoverUrl ?? "",
        // 글 내용 3분할
        textSegments: [
          "이 글의 1단계 내용...",
          "이 글의 2단계 내용...",
          "이 글의 3단계 내용...",
        ],

        // 사지선다 퀴즈
        multipleChoice: MultipleChoiceQuiz(
          question: "이 글의 핵심 주제는 무엇일까요?",
          correctAnswer: "B",
          choices: [
            "A. 전혀 관련 없는 답",
            "B. 읽기 도구의 필요성",
            "C. 읽기 전 활동의 중요성",
            "D. 잘못된 선택지",
          ],
          explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",
        ),

        // OX 퀴즈
        oxQuiz: OXQuiz(
          question: "이 글은 과학 분야이다.",
          correctAnswer: false,
          explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",
        ),
      ),

      // 읽기 후(AR) 화면용 데이터 - 지금은 간단히 예시만
      arData: ArData(
        // 예: 어떤 feature를 쓸지(여기서는 2번, 5번, 9번).
        features: [2, 3, 4],

        featuresCompleted: {
                  "2": false,
                  "3": false,
                  "4": false,
        },

        // featureData에 어떤 형태든 넣을 수 있음
        featureData: {
          "feature2ContentSummary": "내용 요약",
          "feature3Debate": "토론하기",
          "feature3DebateTopic": "환경 보호를 위한 강력한 정책이 더 필요하다",
          "feature4Diagram": "다이어그램",
        },
      ),
    ),

    // ------ stage_002, stage_003, stage_004도 동일하게 작성 ------
    // 예시로 하나 더
    StageData(
      stageId: "stage_004",
      subdetailTitle: "읽기 도구 사용법",
      totalTime: "20",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "쉬움",
      textContents: "읽기 도구의 사용법을 익힙니다.",
      missions: ["토론", "내용 요약", "Tree 구조화"],    
      effects: ["이해력 향상", "읽기 효율 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
      brData: BrData(
        coverImageUrl: stageCoverUrl ?? "",
        keywords: ["#사용법", "#연습하기", "#키워드3"],
      ),
      readingData: ReadingData(
        coverImageUrl: stageCoverUrl ?? "",
        textSegments: ["내용1", "내용2", "내용3"],
        multipleChoice: MultipleChoiceQuiz(
          question: "해당 도구의 장점이 아닌 것은?",
          correctAnswer: "A",
          choices: ["A. 실제로 단점", "B. 장점1", "C. 장점2", "D. 장점3"],
          explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",
        ),
        oxQuiz: OXQuiz(question: "이 도구는 무료이다.", correctAnswer: true, explanation: "맞춤형 읽기 도구는 학습자의 수준과 흥미를 반영하여 적합한 자료를 제공합니다.",),
      ),
      arData: ArData(
        features: [2, 3, 4],

        featuresCompleted: {
                  "2": false,                   
                  "3": false,
                  "4": false,
        },

        featureData: {
          "feature2ContentSummary": "내용 요약",
          "feature3Debate": "토론하기",
          "feature3DebateTopic": "환경 보호를 위한 강력한 정책이 더 필요하다",
          "feature4Diagram": "다이어그램",
        },
      ),
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

