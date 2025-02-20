import 'package:cloud_firestore/cloud_firestore.dart';

// 게시글 정보를 담는 클래스
class Post {
  final String id; // 게시글 ID
  final String title; // 게시글 제목
  final String content; // 게시글 내용
  final List<String> tags; // 게시글 태그 리스트
  final DateTime createdAt; // 게시글 작성일
  final String profileImage; // 작성자의 프로필 이미지
  final String nickname; // 작성자 닉네임
  final int likes; // 좋아요 수
  late final int views; // 조회수 (초기화 지연)
  final String category; // 게시글 카테고리
  final String authorId; // 작성자 ID

  // 생성자: 게시글 데이터를 초기화
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.profileImage,
    required this.nickname,
    required this.likes,
    required this.views,
    required this.category,
    required this.authorId,
  });

  // Firebase에서 받은 데이터를 이용해 Post 객체를 생성하는 팩토리 메서드
  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      id: data['id'] ?? '', // id가 없으면 빈 문자열로 초기화
      title: data['title'] ?? '', // title이 없으면 빈 문자열로 초기화
      content: data['content'] ?? '', // content가 없으면 빈 문자열로 초기화
      tags: List<String>.from(data['tags'] ?? []), // tags가 없으면 빈 리스트로 초기화
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Firestore의 Timestamp를 DateTime으로 변환
      profileImage: data['profileImage']?.isNotEmpty == true
          ? data['profileImage'] // profileImage가 있으면 사용
          : 'assets/images/default_avatar.png', // 없으면 기본 이미지 사용
      nickname: data['nickname'] ?? '익명', // nickname이 없으면 '익명'으로 초기화
      likes: data['likes'] ?? 0, // likes가 없으면 0으로 초기화
      views: data['views'] ?? 0, // views가 없으면 0으로 초기화
      category: data['category'] ?? '', // category가 없으면 빈 문자열로 초기화
      authorId: data['authorId'] ?? '', // authorId가 없으면 빈 문자열로 초기화
    );
  }
}
