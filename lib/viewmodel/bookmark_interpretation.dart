import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveBookmarkInterpretation({
  required String stageId,
  required String subdetailTitle,
  required String selectedText,
  required Map<String, dynamic> interpretationData,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final doc = {
    'dictionaryMeaning': interpretationData['dictionaryMeaning'],
    'contextualMeaning': interpretationData['contextualMeaning'],
    'synonyms': interpretationData['synonyms'],
    'antonyms': interpretationData['antonyms'],
    'createdAt': FieldValue.serverTimestamp(),
    'selectedText': selectedText,
    'stageId': stageId,
    'subdetailTitle': subdetailTitle,
  };

  // 기존의 top-level 'bookmarks' 컬렉션 대신, 사용자 문서의 서브컬렉션으로 저장
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bookmarks')
      .add(doc);
}
