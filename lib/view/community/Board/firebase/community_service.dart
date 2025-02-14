import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 게시글 추가
  Future<String> createPost({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nickname = userDoc.data()?['nickname'] ?? '익명'; // Firestore에서 닉네임 가져오기

      final postRef = _firestore.collection('posts').doc();
      final postData = {
        'id': postRef.id,
        'title': title,
        'content': content,
        'authorId': user.uid,
        'nickname': nickname, // authorName 대신 nickname 저장
        'profileImage': user.photoURL ?? '',
        'tags': tags,
        'likes': 0,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'category': category,
      };

      await postRef.set(postData);
      return postRef.id;
    } catch (e) {
      print('❌ 게시글 작성 오류: $e');
      throw Exception('게시글 작성 실패');
    }
  }


  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    });
  }

  /// 🔹 특정 게시글 가져오기
  Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      return postDoc.exists ? postDoc.data() : null;
    } catch (e) {
      print('❌ 게시글 조회 오류: $e');
      return null;
    }
  }

  /// 🔹 게시글 수정
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) throw Exception("게시글이 존재하지 않습니다.");
      if (postDoc.data()?['authorId'] != user.uid) throw Exception("작성자만 수정할 수 있습니다.");

      await postRef.update({
        'title': title,
        'content': content,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ 게시글 수정 오류: $e');
      throw Exception('게시글 수정 실패');
    }
  }

  /// 🔹 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) throw Exception("게시글이 존재하지 않습니다.");
      if (postDoc.data()?['authorId'] != user.uid) throw Exception("작성자만 삭제할 수 있습니다.");

      await postRef.delete();
    } catch (e) {
      print('❌ 게시글 삭제 오류: $e');
      throw Exception('게시글 삭제 실패');
    }
  }
  /// 🔹 조회수 증가
  Future<void> increasePostViews(String postId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ 조회수 증가 오류: $e');
    }
  }
  /// 🔹 좋아요 토글
  Future<void> toggleLike(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) throw Exception("게시글이 존재하지 않습니다.");

      final data = postDoc.data();
      final List<dynamic> likedBy = data?['likedBy'] ?? [];
      final int currentLikes = data?['likes'] ?? 0;

      if (likedBy.contains(user.uid)) {
        // 이미 좋아요를 눌렀다면 취소
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([user.uid])
        });
      } else {
        // 좋아요 추가
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([user.uid])
        });
      }
    } catch (e) {
      print('❌ 좋아요 오류: $e');
    }
  }

}
