/// File: community_service.dart
/// Purpose: communityservice
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../api/huggingface_toxic_filter.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 게시글 추가
  ///
  /// 주어진 제목, 내용, 카테고리 및 태그를 사용하여 새로운 게시글을 작성합니다.
  /// 작성된 게시글은 Firestore에 저장되며, 작성자의 닉네임과 기본 프로필 이미지도 함께 저장됩니다.
  ///
  /// [title] : 게시글 제목
  /// [content] : 게시글 내용
  /// [category] : 게시글 카테고리
  /// [tags] : 게시글 태그 목록
  ///
  /// 반환값: 생성된 게시글의 ID
  Future<String> createPost({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      // 🔥 여기 추가! - 욕설 필터링
      bool isToxic = await HuggingFaceToxicFilter.isToxic(content);
      if (isToxic) {
        throw Exception("부적절한 표현이 포함되어 있어 게시글을 등록할 수 없습니다.");
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nickname = userDoc.data()?['nickname'] ?? '익명';

      final postRef = _firestore.collection('posts').doc();
      final postData = {
        'id': postRef.id,
        'title': title,
        'content': content,
        'authorId': user.uid,
        'nickname': nickname,
        'profileImage': (user.photoURL != null && user.photoURL!.isNotEmpty)
            ? user.photoURL
            : 'assets/images/default_avatar.png',
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
      throw Exception(e.toString()); // 에러 메시지를 그대로 throw해서 UI에서 처리하게
    }
  }



  /// 🔹 게시글 목록 가져오기
  ///
  /// Firestore에서 게시글 목록을 최신 순으로 가져옵니다.
  ///
  /// 반환값: 게시글 목록의 스트림
  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    });
  }
  // Stream<List<Post>> getPosts() async* {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) throw Exception('로그인이 필요합니다.');
  //
  //   final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //   final blockedUsers = List<String>.from(userDoc.data()?['blockedUsers'] ?? []);
  //
  //   yield* FirebaseFirestore.instance
  //       .collection('posts')
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => Post.fromMap(doc.data()))
  //         .where((post) => !blockedUsers.contains(post.authorId)) // 🔥 여기!
  //         .toList();
  //   });
  // }

  /// 🔹 특정 게시글 가져오기
  ///
  /// 주어진 게시글 ID에 해당하는 게시글을 Firestore에서 가져옵니다.
  ///
  /// [postId] : 게시글 ID
  ///
  /// 반환값: 게시글 데이터 또는 null
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
  ///
  /// 주어진 게시글 ID에 해당하는 게시글을 수정합니다.
  /// 수정할 내용은 제목, 내용, 태그이며, 작성자만 수정할 수 있습니다.
  ///
  /// [postId] : 수정할 게시글 ID
  /// [title] : 수정할 제목
  /// [content] : 수정할 내용
  /// [tags] : 수정할 태그 목록
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      // 🔥 여기 추가 - 수정할 내용에도 욕설 필터링
      bool isToxic = await HuggingFaceToxicFilter.isToxic(content);
      if (isToxic) {
        throw Exception("부적절한 표현이 포함되어 있어 수정할 수 없습니다.");
      }

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
      throw Exception(e.toString());
    }
  }


  /// 🔹 게시글 삭제
  ///
  /// 주어진 게시글 ID에 해당하는 게시글을 삭제합니다.
  /// 삭제는 작성자만 할 수 있습니다.
  ///
  /// [postId] : 삭제할 게시글 ID
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
  ///
  /// 주어진 게시글 ID에 해당하는 게시글의 조회수를 1 증가시킵니다.
  ///
  /// [postId] : 조회수를 증가시킬 게시글 ID
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
  ///
  /// 주어진 게시글에 좋아요를 추가하거나 제거합니다.
  /// 사용자가 이미 좋아요를 눌렀다면 취소하고, 그렇지 않으면 좋아요를 추가합니다.
  ///
  /// [postId] : 좋아요를 토글할 게시글 ID
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
  Future<void> reportPost({
    required String postId,
    required String reason,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      await FirebaseFirestore.instance.collection('reports').add({
        'reportedPostId': postId,
        'reporterId': user.uid,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ 신고 오류: $e');
      throw Exception('신고 실패');
    }
  }
  Future<void> blockUser(String blockedUserId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId])
    });
  }

}
