import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class WordInterpretation {
  final String id;
  final String stageId;           // 스테이지 식별자
  final String subdetailTitle;    // StageData의 subdetailTitle
  final String selectedText;      // 사용자가 선택한 텍스트
  final String dictionaryMeaning; // 사전적 의미
  final String contextualMeaning; // 문맥상 의미
  final List<String> synonyms;    // 유사어
  final List<String> antonyms;    // 반의어
  final DateTime createdAt;       // 생성일

  WordInterpretation({
    required this.id,
    required this.stageId,
    required this.subdetailTitle,
    required this.selectedText,
    required this.dictionaryMeaning,
    required this.contextualMeaning,
    required this.synonyms,
    required this.antonyms,
    required this.createdAt,
  });

  // Firestore에 저장할 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'stageId': stageId,
      'subdetailTitle': subdetailTitle,
      'selectedText': selectedText,
      'dictionaryMeaning': dictionaryMeaning,
      'contextualMeaning': contextualMeaning,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Firestore 데이터로부터 WordInterpretation 생성
  factory WordInterpretation.fromMap(String id, Map<String, dynamic> map) {
    return WordInterpretation(
      id: id,
      stageId: map['stageId'] as String,
      subdetailTitle: map['subdetailTitle'] as String,
      selectedText: map['selectedText'] as String,
      dictionaryMeaning: map['dictionaryMeaning'] as String,
      contextualMeaning: map['contextualMeaning'] as String,
      synonyms: List<String>.from(map['synonyms']),
      antonyms: List<String>.from(map['antonyms']),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class WordInterpretationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자의 wordInterpretations subcollection 참조
  CollectionReference get _wordInterpretationCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('사용자 인증이 필요합니다.');
    }
    return _firestore.collection('users').doc(userId).collection('wordInterpretations');
  }

  Future<void> addWordInterpretation(WordInterpretation wordInterpretation) async {
    await _wordInterpretationCollection.doc(wordInterpretation.id).set(wordInterpretation.toMap());
  }

  Future<void> deleteWordInterpretation(String id) async {
    await _wordInterpretationCollection.doc(id).delete();
  }

  Future<List<WordInterpretation>> fetchWordInterpretations() async {
    final querySnapshot = await _wordInterpretationCollection.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return WordInterpretation.fromMap(doc.id, data);
    }).toList();
  }
}
