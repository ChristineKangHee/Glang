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
  final stageCoverUrls = await Future.wait([
    getCoverImageUrl("stage_001.png"),
    getCoverImageUrl("stage_002.png"),
    getCoverImageUrl("stage_003.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
    getCoverImageUrl("stage_004.png"),
  ]);
  // print("[_createDefaultStages] stageCoverUrl: $stageCoverUrl");

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
        coverImageUrl: stageCoverUrls[0] ?? "",
        keywords: ["#읽기능력", "#맞춤형도구", "#피드백"],
      ),

      // 읽기 중(READING) 화면용 데이터
      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[0] ?? "",
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
            "subtitle": "<환경 보호와 지속 가능한 미래>",
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
                    ]
                  }
                ]
              }
            ],
            "correctAnswers": {
              "Root": "환경 보호",
              "Child 1": "자원 절약",
              "Grandchild 1": "중요성",
              "Grandchild 2": "기술 발전 지원",
              "Child 2": "기후 변화 대응",
              "Grandchild 3": "기업과 국가의 노력",
              "Grandchild 4": "긍정적인 변화",
              "Child 3": "지속 가능성",
              "Grandchild 5": "도전 과제",
            },
            "wordList": [
              "환경 보호",
              "자원 절약",
              "중요성",
              "기술 발전 지원",
              "기후 변화 대응",
              "기업과 국가의 노력",
              "긍정적인 변화",
              "지속 가능성",
              "도전 과제",
            ]
          }
        },
      ),
    ),

    // ------ stage_002, stage_003, stage_004도 동일하게 작성 ------
    // 예시로 하나 더
    StageData(
      stageId: "stage_002",
      subdetailTitle: "디지털 교육의 효과: 전통적 교육 방법과의 비교",
      totalTime: "20",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "쉬움",
      textContents: "디지털 교육의 효과를 배웁니다.",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["이해력 향상", "읽기 효율 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },
      brData: BrData(
        coverImageUrl: stageCoverUrls[1] ?? "",
        keywords: ["#디지털 교육", "#학습 성과", "#사회적 상호작용"],
      ),
      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[1] ?? "",
        textSegments: [
          "디지털 교육은 학생들에게 다양한 학습 자원을 제공하며, 이를 통해 전통적인 교실 수업에 비해 더 높은 유연성과 접근성을 제공한다. 여러 연구들은 디지털 교육이 학습 성과를 향상시킬 수 있음을 보여주었으며, 특히 시간과 장소에 구애받지 않는 특성 덕분에 교육의 효과를 극대화할 수 있다고 주장한다. ",
          "그러나 디지털 교육에는 몇 가지 단점도 존재한다. 일부 학생들은 자율 학습에서 어려움을 겪고 있으며, 온라인 수업의 경우 사회적 상호작용이 부족하다는 비판이 제기된다. ",
          "또한, 전통적인 교육 방법은 여전히 중요한 역할을 하며, 학생들 간의 관계 형성과 교사의 역할이 중요하다는 주장이 지속적으로 제기되고 있다. 이러한 점들을 종합적으로 고려했을 때, 디지털 교육과 전통 교육은 상호 보완적으로 사용되어야 한다는 결론을 도출할 수 있다."
        ],
        multipleChoice: MultipleChoiceQuiz(
          question: "디지털 교육의 장점은 무엇인가?",
          correctAnswer: "A",
          choices: ["A. 학습 성과 향상", "B. 사회적 상호작용 증가", "C. 자율적인 학습 증가", "D. 교사의 역할 감소"],
          explanation: "디지털 교육은 학습 자원을 다양화하여 성과 향상에 기여한다고 설명됩니다.",
        ),
        oxQuiz: OXQuiz(question: "디지털 교육이 전통적인 교육 방법에 비해 유연성을 높인다고 주장하는 내용은 맞는가?", correctAnswer: true, explanation: "디지털 교육이 유연성과 접근성을 높여 전통적인 교육 방법에 비해 장점이 있다고 언급됩니다.",),
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
          "feature3DebateTopic": "디지털 교육이 전통적인 교육을 대체할 수 있다.",
          "feature4Diagram": {
            "title": "트리 구조에 알맞는 단어를 넣어주세요!",
            "subtitle": "<디지털 교육의 효과>",
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
              "Root": "디지털 교육",
              "Child 1": "장점",
              "Grandchild 1": "유연성과 접근성 향상",
              "Grandchild 2": "학습 성과 향상",
              "Child 2": "단점",
              "Grandchild 3": "자율 학습의 어려움",
              "Grandchild 4": "사회적 상호작용 부족",
              "Child 3": "전통 교육의 중요성",
              "Grandchild 5": "학생 간 관계 형성",
              "Grandchild 6": "교사의 역할 강조"
            },
            "wordList": [
              "디지털 교육",
              "장점",
              "유연성과 접근성 향상",
              "학습 성과 향상",
              "단점",
              "자율 학습의 어려움",
              "사회적 상호작용 부족",
              "전통 교육의 중요성",
              "학생 간 관계 형성",
              "교사의 역할 강조"
            ]
          }
        },
      ),
    ),

    StageData(
      stageId: "stage_003",
      subdetailTitle: "비오는 날의 기억",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.locked, // 첫 스테이지만 시작 가능
      difficultyLevel: "쉬움",
      textContents: "문학 작품을 읽어 봅시다.",
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
        coverImageUrl: stageCoverUrls[2] ?? "",
        keywords: ["#비 오는 날", "#기억", "#그리움"],
      ),

      // 읽기 중(READING) 화면용 데이터
      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[2] ?? "",
        // 글 내용 3분할
        textSegments: [
          "그날, 비가 내리고 있었다. 나는 창밖을 바라보며 오랜만에 느껴보는 차가운 공기에 몸을 맡겼다. 비가 내리는 소리는 어린 시절의 기억을 불러일으켰다. 어린 시절, 부모님과 함께 떠났던 여행에서의 추억, 그리고 친구와 함께 뛰놀던 학교 운동장의 모습들이 떠올랐다. ",
          "그때의 나와 지금의 나는 달라져 있었다. 그러나 비 오는 날, 그 시절의 기억들이 떠오르면서 나는 다시 한 번 그때로 돌아가고 싶은 마음이 들었다. 내 안에 깊숙이 새겨진 그 기억들은 시간이 지나도 여전히 살아있었다. ",
          "그리움과 향수의 감정은 나를 짓누르며, 나는 잠시 과거 속으로 빠져들었다. 그 순간, 비 오는 날의 기억은 나에게 가장 소중한 추억이 되었다.",
        ],

        // 사지선다 퀴즈
        multipleChoice: MultipleChoiceQuiz(
          question: "주인공이 느낀 감정은 무엇인가?",
          correctAnswer: "C",
          choices: [
            "A. 불안과 긴장",
            "B. 기쁨과 즐거움",
            "C. 향수와 그리움",
            "D. 혼란과 당황",
          ],
          explanation: "주인공은 비 오는 날, 어린 시절의 기억을 떠올리며 향수와 그리움을 느낍니다.",
        ),

        // OX 퀴즈
        oxQuiz: OXQuiz(
          question: "주인공은 어린 시절의 추억을 떠올리며 그리움을 느꼈다고 주장하는 내용은 맞는가?",
          correctAnswer: true,
          explanation: "\"어린 시절의 기억을 떠올리며 그리움을 느꼈다.\" 문장에서 확인할 수 있습니다.",
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
          "feature3DebateTopic": "어린 시절의 기억은 성인이 된 후에도 큰 영향을 미친다.",
          "feature4Diagram": {
            "title": "트리 구조에 알맞는 단어를 넣어주세요!",
            "subtitle": "<비오는 날의 기억>",
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
                    ]
                  }
                ]
              }
            ],
            "correctAnswers": {
              "Root": "비 오는 날의 기억",
              "Child 1": "어린 시절의 기억",
              "Grandchild 1": "부모님과의 여행",
              "Grandchild 2": "학교 운동장",
              "Child 2": "그리움과 향수",
              "Grandchild 3": "추억의 소중함",
              "Grandchild 4": "과거로 돌아가고 싶은 마음",
              "Child 3": "비 오는 날의 소중한 추억",
              "Grandchild 5": "가장 소중한 추억",
            },
            "wordList": [
              "비 오는 날의 기억",
              "학교 운동장",
              "부모님과의 여행",
              "어린 시절의 기억",
              "그리움과 향수",
              "추억의 소중함",
              "과거로 돌아가고 싶은 마음",
              "전통 교육의 중요성",
              "가장 소중한 추억",
            ]
          }
        },
      ),
    ),

    // stage 004 부턴 더미
    StageData(
      stageId: "stage_004",
      subdetailTitle: "인공지능과 미래 사회",
      totalTime: "35",
      achievement: 0,
      status: StageStatus.locked, // 첫 스테이지만 시작 가능, 이후 스테이지는 잠김
      difficultyLevel: "보통",
      textContents: "인공지능과 미래 사회",
      missions: ["토론", "내용 요약", "Tree 구조화"], // 기존과 동일
      effects: ["논리적 사고 향상", "문제 해결 능력 강화"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      // 읽기 전(BR) 화면용 데이터
      brData: BrData(
        coverImageUrl: stageCoverUrls[3] ?? "",
        keywords: ["#AI", "#미래기술", "#사회변화"],
      ),

      // 읽기 중(READING) 화면용 데이터
      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[3] ?? "",
        textSegments: [
          "인공지능(AI)은 빠른 속도로 발전하며 다양한 산업에서 핵심적인 역할을 수행하고 있다. AI 기술이 발전함에 따라 의료, 금융, 교육 등의 분야에서 혁신적인 변화를 만들어 내고 있다.",
          "그러나 AI의 발전은 일자리 감소, 윤리적 문제, 데이터 프라이버시 등 여러 도전 과제를 동반한다. 특히, AI가 인간의 결정을 대체하는 과정에서 책임과 신뢰의 문제가 중요하게 다루어지고 있다.",
          "미래 사회에서 AI는 더욱 정교해질 것이며, 인간과 협력하는 방식이 중요한 화두가 될 것이다. AI를 효과적으로 활용하면서도 윤리적 문제를 해결하는 것이 앞으로의 과제가 될 것이다."
        ],

        // 사지선다 퀴즈
        multipleChoice: MultipleChoiceQuiz(
            question: "이 글에서 강조하는 AI의 주요 과제는 무엇인가?",
            correctAnswer: "C",
            choices: [
              "A. AI의 경제적 이점",
              "B. AI 기술 발전 속도",
              "C. AI의 윤리적 문제와 신뢰성",
              "D. AI를 활용한 자동화 시스템",
            ],
            explanation: "글에서 AI의 발전과 함께 윤리적 문제와 신뢰성이 주요 도전 과제임을 강조하고 있습니다."
        ),

        // OX 퀴즈
        oxQuiz: OXQuiz(
            question: "AI 기술은 이미 의료 분야에서 활용되고 있으며, 앞으로도 발전할 가능성이 높다.",
            correctAnswer: true,
            explanation: "AI는 현재 의료 진단, 치료 보조 등에 사용되고 있으며, 향후 발전 가능성이 큽니다."
        ),
      ),

      // 읽기 후(AR) 화면용 데이터
      arData: ArData(
        features: [2, 3, 4], // 기존과 동일
        featuresCompleted: {
          "2": false,
          "3": false,
          "4": false,
        },
        featureData: {
          "feature2ContentSummary": "내용 요약",
          "feature3Debate": "토론하기",
          "feature3DebateTopic": "AI 기술 발전이 일자리 감소를 초래하는가?",
          "feature4Diagram": {
            "title": "트리 구조에 알맞는 단어를 넣어주세요!",
            "subtitle": "<AI와 미래 사회>",
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
              "Root": "AI 기술",
              "Child 1": "문제점",
              "Grandchild 1": "일자리 감소",
              "Grandchild 2": "윤리적 문제",
              "Child 2": "해결방안",
              "Grandchild 3": "AI 규제 강화",
              "Grandchild 4": "데이터 보호 정책",
              "Child 3": "기대효과",
              "Grandchild 5": "자동화 효율 증가",
              "Grandchild 6": "새로운 일자리 창출"
            },
            "wordList": [
              "AI 기술",
              "문제점",
              "일자리 감소",
              "윤리적 문제",
              "해결방안",
              "AI 규제 강화",
              "데이터 보호 정책",
              "기대효과",
              "자동화 효율 증가",
              "새로운 일자리 창출"
            ]
          }
        },
      ),
    ),
    // stage 005
    StageData(
      stageId: "stage_005",
      subdetailTitle: "우주 탐사와 인류의 미래",
      totalTime: "40",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "어려움",
      textContents: "우주 탐사와 인류의 미래",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["과학적 사고력 향상", "창의적 문제 해결"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[4] ?? "",
        keywords: ["#우주", "#미래사회", "#기술혁신"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[4] ?? "",
        textSegments: [
          "인류는 오랫동안 우주 탐사를 통해 미지의 영역을 개척하고자 노력해왔다. 과거의 달 착륙부터 현재의 화성 탐사까지, 기술 발전이 우주 개발을 가속화하고 있다.",
          "우주 탐사는 단순한 모험이 아니라 인류 생존과 직결될 수도 있다. 기후 변화, 자원 부족 등의 문제를 해결하기 위한 새로운 거주지를 찾기 위한 연구도 진행되고 있다.",
          "그러나 우주 탐사는 엄청난 비용이 들며, 윤리적 논쟁도 발생한다. 과연 우리는 우주에 정착할 준비가 되었는가?"
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "우주 탐사의 가장 중요한 이유는 무엇인가?",
            correctAnswer: "D",
            choices: [
              "A. 새로운 행성을 탐험하기 위한 호기심",
              "B. 우주 기술의 발전",
              "C. 경제적 이익 창출",
              "D. 인류 생존 가능성 확대",
            ],
            explanation: "우주 탐사는 기후 변화나 자원 부족 문제를 해결하기 위한 방안으로도 연구되고 있습니다."
        ),

        oxQuiz: OXQuiz(
            question: "우주 탐사는 비용 문제로 인해 국가적 차원에서만 진행될 수 있다.",
            correctAnswer: false,
            explanation: "최근 민간 기업들도 우주 탐사에 적극적으로 참여하고 있습니다."
        ),
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
          "feature3Debate": "우주 식민지는 필요할까?",
          "feature4Diagram": {
            "title": "우주 탐사의 중요 요소",
            "subtitle": "<우주 탐사와 인류의 미래>",
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
                  }
                ]
              }
            ],
            "correctAnswers": {
              "Root": "우주 탐사",
              "Child 1": "이점",
              "Grandchild 1": "자원 탐사",
              "Grandchild 2": "신기술 개발",
              "Child 2": "문제점",
              "Grandchild 3": "비용 부담",
              "Grandchild 4": "윤리적 논쟁"
            },
            "wordList": [
              "우주 탐사",
              "이점",
              "자원 탐사",
              "신기술 개발",
              "문제점",
              "비용 부담",
              "윤리적 논쟁"
            ]
          }
        },
      ),
    ),
    // stage 006
    StageData(
      stageId: "stage_006",
      subdetailTitle: "지속 가능한 에너지",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "쉬움",
      textContents: "지속 가능한 에너지",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["환경 보호 의식 향상", "창의적 해결력 강화"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[5] ?? "",
        keywords: ["#재생에너지", "#환경", "#기후변화"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[5] ?? "",
        textSegments: [
          "전 세계적으로 화석 연료 사용이 줄어들고 있으며, 지속 가능한 에너지가 중요한 이슈로 떠오르고 있다.",
          "태양광, 풍력, 수소 에너지는 친환경적이면서도 장기적으로 경제적 이점을 제공하는 대안으로 평가받고 있다.",
          "그러나 신재생 에너지는 초기 비용이 높고, 에너지 저장 기술이 아직 완벽하지 않다는 단점도 존재한다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "지속 가능한 에너지의 가장 큰 장점은?",
            correctAnswer: "A",
            choices: [
              "A. 환경 오염 감소",
              "B. 무한한 에너지 생산",
              "C. 비용 절감",
              "D. 높은 에너지 효율",
            ],
            explanation: "지속 가능한 에너지는 화석 연료 대비 환경 오염을 줄이는 것이 가장 큰 장점입니다."
        ),

        oxQuiz: OXQuiz(
            question: "태양광과 풍력 에너지는 화석 연료보다 에너지 효율이 더 높다.",
            correctAnswer: false,
            explanation: "현재 기술로는 화석 연료가 더 높은 에너지 밀도를 가지지만, 친환경성이 중요합니다."
        ),
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
          "feature3Debate": "원자력 발전은 지속 가능한 에너지원인가?",
          "feature4Diagram": {
            "title": "지속 가능한 에너지",
            "subtitle": "<재생 에너지원>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"},
                  {"id": "Child 3"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "재생 에너지",
              "Child 1": "태양광",
              "Child 2": "풍력",
              "Child 3": "수소"
            },
            "wordList": [
              "재생 에너지",
              "태양광",
              "풍력",
              "수소"
            ]
          }
        },
      ),
    ),
    // stage 007
    StageData(
      stageId: "stage_007",
      subdetailTitle: "빅데이터와 개인정보 보호",
      totalTime: "35",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "빅데이터와 개인정보 보호",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["논리적 사고 향상", "데이터 이해력 증가"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[6] ?? "",
        keywords: ["#빅데이터", "#개인정보", "#프라이버시"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[6] ?? "",
        textSegments: [
          "빅데이터는 우리의 일상에서 점점 더 중요한 역할을 하고 있으며, 기업과 정부 기관에서 활용도가 높아지고 있다.",
          "그러나 데이터 수집 과정에서 개인정보 보호 문제가 제기되고 있다. 개인 정보 유출 사고가 증가하면서 보안 강화의 필요성이 커지고 있다.",
          "우리는 빅데이터를 활용하면서도, 적절한 보안 정책과 윤리적 기준을 마련하는 것이 중요하다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "빅데이터 활용 시 가장 중요한 문제는?",
            correctAnswer: "B",
            choices: [
              "A. 데이터 저장 공간",
              "B. 개인정보 보호",
              "C. 데이터 처리 속도",
              "D. 빅데이터 분석 기술 발전",
            ],
            explanation: "빅데이터는 개인정보 보호 문제와 함께 사용될 때 윤리적 이슈가 발생할 수 있습니다."
        ),

        oxQuiz: OXQuiz(
            question: "빅데이터는 개인정보를 수집하지 않고 활용할 수 있다.",
            correctAnswer: false,
            explanation: "많은 경우 개인정보가 포함된 데이터를 분석하며, 보호 조치가 필요합니다."
        ),
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
          "feature3Debate": "기업의 데이터 수집이 개인의 사생활을 침해할까?",
          "feature4Diagram": {
            "title": "빅데이터 활용과 개인정보 보호",
            "subtitle": "<빅데이터의 이점과 위험>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "빅데이터",
              "Child 1": "이점",
              "Child 2": "위험"
            },
            "wordList": [
              "빅데이터",
              "이점",
              "위험"
            ]
          }
        },
      ),
    ),
    // stage 008
    StageData(
      stageId: "stage_008",
      subdetailTitle: "미래 교통과 스마트 모빌리티",
      totalTime: "40",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "미래 교통과 스마트 모빌리티",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["기술 이해력 증가", "창의적 사고력 향상"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[7] ?? "",
        keywords: ["#자율주행", "#스마트시티", "#미래교통"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[7] ?? "",
        textSegments: [
          "자율주행차, 드론 택시, 하이퍼루프 같은 혁신적인 기술이 미래 교통 시스템을 변화시키고 있다.",
          "스마트 모빌리티는 교통 체증 해소와 환경 보호에 기여할 수 있다. 특히, 자율주행차는 사고를 줄이고 운전 효율성을 높이는 데 중요한 역할을 한다.",
          "하지만, 이러한 기술의 도입에는 법적, 윤리적 문제와 함께 인프라 구축이 필요하다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "스마트 모빌리티의 가장 큰 장점은?",
            correctAnswer: "A",
            choices: [
              "A. 교통 체증 감소",
              "B. 빠른 차량 속도",
              "C. 높은 유지보수 비용",
              "D. 더 많은 운전자가 필요함",
            ],
            explanation: "스마트 모빌리티는 자율주행과 교통 최적화를 통해 교통 체증을 줄이는 것이 핵심 목표입니다."
        ),

        oxQuiz: OXQuiz(
            question: "자율주행차는 현재 완벽하게 실현된 기술이다.",
            correctAnswer: false,
            explanation: "현재 기술적으로 발전 중이며, 아직 완벽한 자율주행은 이루어지지 않았습니다."
        ),
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
          "feature3Debate": "자율주행차는 사고를 줄일 수 있을까?",
          "feature4Diagram": {
            "title": "미래 교통과 스마트 모빌리티",
            "subtitle": "<스마트 교통 시스템>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "스마트 모빌리티",
              "Child 1": "이점",
              "Child 2": "도전 과제"
            },
            "wordList": [
              "스마트 모빌리티",
              "이점",
              "도전 과제"
            ]
          }
        },
      ),
    ),
    // stage 009
    StageData(
      stageId: "stage_009",
      subdetailTitle: "기후 변화와 환경 문제",
      totalTime: "35",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "기후 변화와 환경 문제",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["환경 의식 향상", "문제 해결 능력 증대"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[8] ?? "",
        keywords: ["#기후변화", "#환경보호", "#탄소중립"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[8] ?? "",
        textSegments: [
          "기후 변화는 전 세계적으로 중요한 환경 문제 중 하나이며, 산업화 이후 온실가스 배출 증가로 인해 심각한 영향을 미치고 있다.",
          "정부와 기업은 탄소 배출을 줄이고 지속 가능한 에너지를 활용하는 등 다양한 노력을 기울이고 있다.",
          "그러나 개인의 실천도 중요하다. 재활용을 생활화하고, 에너지 절약을 실천하는 것이 기후 변화 대응에 도움이 될 수 있다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "기후 변화의 주요 원인은 무엇인가?",
            correctAnswer: "A",
            choices: [
              "A. 온실가스 배출 증가",
              "B. 산소 감소",
              "C. 태양 에너지 부족",
              "D. 해양 생태계 변화",
            ],
            explanation: "온실가스 배출이 지구 온난화를 유발하는 주요 요인입니다."
        ),

        oxQuiz: OXQuiz(
            question: "기후 변화는 인간의 활동과 무관하다.",
            correctAnswer: false,
            explanation: "기후 변화는 산업화 이후 인간의 활동이 주요 원인으로 작용하고 있습니다."
        ),
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
          "feature3Debate": "기후 변화 대응을 위해 강력한 법적 규제가 필요할까?",
          "feature4Diagram": {
            "title": "기후 변화의 원인과 해결 방안",
            "subtitle": "<지속 가능한 미래>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "기후 변화",
              "Child 1": "원인",
              "Child 2": "해결 방안"
            },
            "wordList": [
              "기후 변화",
              "원인",
              "해결 방안"
            ]
          }
        },
      ),
    ),
    // stage 010
    StageData(
      stageId: "stage_010",
      subdetailTitle: "미래의 직업과 AI",
      totalTime: "30",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "미래의 직업과 AI",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["창의적 문제 해결", "AI 기술 이해"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[9] ?? "",
        keywords: ["#AI", "#미래직업", "#자동화"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[9] ?? "",
        textSegments: [
          "AI와 자동화 기술의 발전으로 많은 직업이 변화하고 있으며, 일부 직업은 사라지고 새로운 직업이 탄생하고 있다.",
          "특히, 데이터 분석가, AI 엔지니어, 로봇 프로그래머와 같은 직업이 인기를 끌고 있다.",
          "AI 시대에서 중요한 것은 인간이 창의성과 감성을 발휘하여 기술을 효과적으로 활용하는 것이다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "미래에 AI가 대체하기 어려운 직업은?",
            correctAnswer: "C",
            choices: [
              "A. 데이터 입력 전문가",
              "B. 공장 조립원",
              "C. 심리 상담사",
              "D. 콜센터 직원",
            ],
            explanation: "심리 상담사는 인간의 감성과 공감을 바탕으로 하기 때문에 AI가 완전히 대체하기 어렵습니다."
        ),

        oxQuiz: OXQuiz(
            question: "AI는 모든 직업을 완전히 대체할 것이다.",
            correctAnswer: false,
            explanation: "AI는 자동화가 가능하지만, 창의성과 감성이 필요한 직업은 대체하기 어렵습니다."
        ),
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
          "feature3Debate": "AI가 인간의 직업을 빼앗는가?",
          "feature4Diagram": {
            "title": "미래의 직업과 AI",
            "subtitle": "<AI의 역할>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "AI의 영향",
              "Child 1": "새로운 직업",
              "Child 2": "대체된 직업"
            },
            "wordList": [
              "AI의 영향",
              "새로운 직업",
              "대체된 직업"
            ]
          }
        },
      ),
    ),
    // stage 011
    StageData(
      stageId: "stage_011",
      subdetailTitle: "유전자 편집과 생명윤리",
      totalTime: "40",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "어려움",
      textContents: "유전자 편집과 생명윤리",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["과학적 사고력 향상", "윤리적 사고 증진"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[10] ?? "",
        keywords: ["#유전자편집", "#생명윤리", "#의료기술"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[10] ?? "",
        textSegments: [
          "유전자 편집 기술은 질병 치료, 농업 혁신 등 다양한 분야에서 혁신적인 변화를 가져오고 있다.",
          "특히, CRISPR 기술을 활용하면 특정 유전자를 정밀하게 조작하여 유전병을 예방하거나 치료할 수 있다.",
          "그러나 인간의 유전자를 수정하는 것이 윤리적으로 옳은지에 대한 논란이 지속되고 있다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "유전자 편집 기술의 가장 큰 윤리적 문제는?",
            correctAnswer: "D",
            choices: [
              "A. 기술 개발 비용",
              "B. 적용 속도",
              "C. 치료 가능 질병 수",
              "D. 인간의 본질적 변화 가능성",
            ],
            explanation: "유전자 편집 기술이 인간의 본질적 특성을 바꿀 수 있어 윤리적 문제가 제기됩니다."
        ),

        oxQuiz: OXQuiz(
            question: "CRISPR 기술을 이용하면 모든 유전병을 치료할 수 있다.",
            correctAnswer: false,
            explanation: "CRISPR 기술은 유망하지만, 모든 유전병 치료가 가능하지는 않습니다."
        ),
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
          "feature3Debate": "유전자 편집은 어디까지 허용해야 하는가?",
          "feature4Diagram": {
            "title": "유전자 편집과 윤리적 논란",
            "subtitle": "<유전자 편집의 장점과 단점>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "유전자 편집",
              "Child 1": "이점",
              "Child 2": "윤리적 문제"
            },
            "wordList": [
              "유전자 편집",
              "이점",
              "윤리적 문제"
            ]
          }
        },
      ),
    ),
    // stage 012
    StageData(
      stageId: "stage_012",
      subdetailTitle: "글로벌화와 문화 다양성",
      totalTime: "35",
      achievement: 0,
      status: StageStatus.locked,
      difficultyLevel: "보통",
      textContents: "글로벌화와 문화 다양성",
      missions: ["토론", "내용 요약", "Tree 구조화"],
      effects: ["다문화 이해력 향상", "세계화 감각 강화"],
      activityCompleted: {
        "beforeReading": false,
        "duringReading": false,
        "afterReading": false,
      },

      brData: BrData(
        coverImageUrl: stageCoverUrls[11] ?? "",
        keywords: ["#글로벌화", "#문화다양성", "#세계시민"],
      ),

      readingData: ReadingData(
        coverImageUrl: stageCoverUrls[11] ?? "",
        textSegments: [
          "세계화는 국가 간 교류를 확대하고 경제, 문화, 정치적으로 큰 영향을 미치고 있다.",
          "인터넷과 교통 기술의 발전으로 세계는 더욱 연결되었으며, 다양한 문화가 공존하는 사회가 형성되고 있다.",
          "그러나 글로벌화는 문화적 동질화 문제와 지역 고유 문화의 보호 문제를 동시에 야기할 수 있다."
        ],

        multipleChoice: MultipleChoiceQuiz(
            question: "글로벌화로 인해 발생하는 문제점은?",
            correctAnswer: "B",
            choices: [
              "A. 국가 간 교류 증가",
              "B. 문화적 동질화",
              "C. 경제 성장",
              "D. 국제 협력 확대",
            ],
            explanation: "글로벌화가 진행됨에 따라 전통 문화가 사라지고 문화적 동질화가 진행될 가능성이 있습니다."
        ),

        oxQuiz: OXQuiz(
            question: "글로벌화는 모든 국가에 동일한 영향을 미친다.",
            correctAnswer: false,
            explanation: "국가마다 경제적, 정치적 상황이 다르기 때문에 글로벌화의 영향도 다르게 나타납니다."
        ),
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
          "feature3Debate": "글로벌화는 국가의 문화를 약화시키는가?",
          "feature4Diagram": {
            "title": "글로벌화의 긍정적 및 부정적 영향",
            "subtitle": "<세계화의 장단점>",
            "treeStructure": [
              {
                "id": "Root",
                "children": [
                  {"id": "Child 1"},
                  {"id": "Child 2"}
                ]
              }
            ],
            "correctAnswers": {
              "Root": "글로벌화",
              "Child 1": "이점",
              "Child 2": "문제점"
            },
            "wordList": [
              "글로벌화",
              "이점",
              "문제점"
            ]
          }
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

