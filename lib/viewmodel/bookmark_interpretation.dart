import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 단어 해석을 북마크에 저장하는 함수
Future<void> saveBookmarkInterpretation({
  required String stageId, // 단계 ID
  required String subdetailTitle, // 세부 제목
  required String selectedText, // 선택된 텍스트
  required Map<String, dynamic> interpretationData, // 해석 데이터
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final doc = {
    'dictionaryMeaning': interpretationData['dictionaryMeaning'], // 사전적 의미
    'contextualMeaning': interpretationData['contextualMeaning'], // 문맥적 의미
    'synonyms': interpretationData['synonyms'], // 유의어
    'antonyms': interpretationData['antonyms'], // 반의어
    'createdAt': FieldValue.serverTimestamp(), // 생성 시간 (서버 기준)
    'selectedText': selectedText, // 선택된 텍스트
    'stageId': stageId, // 단계 ID
    'subdetailTitle': subdetailTitle, // 세부 제목
  };

  // 기존의 최상위 'bookmarks' 컬렉션이 아니라, 사용자의 문서 내 'bookmarks' 서브컬렉션에 저장
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bookmarks')
      .add(doc);
}

/// 문장 해석을 북마크에 저장하는 함수
Future<void> saveBookmarkSentenceInterpretation({
  required String stageId, // 단계 ID
  required String subdetailTitle, // 세부 제목
  required String selectedText, // 선택된 텍스트
  required Map<String, dynamic> interpretationData, // 해석 데이터
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final doc = {
    // 문장 해석의 경우 단어 해석과 달리 사전적 의미/유의어/반의어가 없으므로 기본값 설정
    'dictionaryMeaning': "정보 없음", // 사전적 의미 없음
    'contextualMeaning': interpretationData['contextualMeaning'], // 문맥적 의미
    'synonyms': [], // 유의어 없음
    'antonyms': [], // 반의어 없음
    'summary': interpretationData['summary'], // 요약 정보
    'createdAt': FieldValue.serverTimestamp(), // 생성 시간 (서버 기준)
    'selectedText': selectedText, // 선택된 텍스트
    'stageId': stageId, // 단계 ID
    'subdetailTitle': subdetailTitle, // 세부 제목
    'type': 'sentence', // 문장 타입 표시
  };

  // 사용자 문서 내 'bookmarks' 서브컬렉션에 저장
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bookmarks')
      .add(doc);
}
