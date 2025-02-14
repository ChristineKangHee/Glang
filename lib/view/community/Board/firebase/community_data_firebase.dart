import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final String profileImage;
  final String nickname;
  final int likes;
  late final int views;
  final String category;

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
  });

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileImage: data['profileImage'] ?? '',
      nickname: data['nickname'] ?? '익명',
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      category: data['category'] ?? '',
    );
  }
}
