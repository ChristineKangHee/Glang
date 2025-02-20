/// File: memo_service.dart
/// Purpose: memo service 함수
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/memo_model.dart';

class MemoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자의 memos 하위 컬렉션(subcollection) 참조 반환
  CollectionReference get _memoCollection {
    final userId = _auth.currentUser?.uid; // 현재 로그인된 사용자의 UID 가져오기
    if (userId == null) {
      throw Exception('사용자 인증이 필요합니다.'); // 사용자 인증이 되지 않은 경우 예외 발생
    }
    return _firestore.collection('users').doc(userId).collection('memos'); // 특정 사용자의 memos 컬렉션 참조 반환
  }

  // 새로운 메모 추가
  Future<void> addMemo(Memo memo) async {
    await _memoCollection.doc(memo.id).set(memo.toMap()); // Firestore에 메모 데이터를 저장
  }

  // 기존 메모 수정
  Future<void> updateMemo(Memo memo) async {
    await _memoCollection.doc(memo.id).update({
      'note': memo.note, // 메모 내용만 업데이트
    });
  }

  // 메모 삭제
  Future<void> deleteMemo(String id) async {
    await _memoCollection.doc(id).delete(); // Firestore에서 해당 메모 삭제
  }

  // 모든 메모 가져오기
  Future<List<Memo>> fetchMemos() async {
    final querySnapshot = await _memoCollection.get(); // Firestore에서 메모 목록 조회
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>; // Firestore 문서를 Map 형태로 변환
      return Memo.fromMap(doc.id, data); // Memo 객체로 변환하여 리스트에 추가
    }).toList();
  }
}
