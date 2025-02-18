import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/memo_model.dart';

class MemoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자의 memos subcollection 참조
  CollectionReference get _memoCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('사용자 인증이 필요합니다.');
    }
    return _firestore.collection('users').doc(userId).collection('memos');
  }

  Future<void> addMemo(Memo memo) async {
    await _memoCollection.doc(memo.id).set(memo.toMap());
  }

  Future<void> updateMemo(Memo memo) async {
    await _memoCollection.doc(memo.id).update({
      'note': memo.note,
    });
  }

  Future<void> deleteMemo(String id) async {
    await _memoCollection.doc(id).delete();
  }

  Future<List<Memo>> fetchMemos() async {
    final querySnapshot = await _memoCollection.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Memo.fromMap(doc.id, data);
    }).toList();
  }
}
