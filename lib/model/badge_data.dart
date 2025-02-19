// lib/model/badge_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class Badge {
  final String id;
  final String name;
  final bool obtained;
  final String description;
  final String howToEarn;
  final String? imageUrl;

  Badge({
    required this.id,
    required this.name,
    required this.obtained,
    required this.description,
    required this.howToEarn,
    this.imageUrl,
  });

  factory Badge.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Badge(
      id: doc.id,
      name: data['name'] ?? '이름 없음',
      obtained: data['obtained'] ?? false,
      description: data['description'] ?? '설명이 없습니다.',
      howToEarn: data['howToEarn'] ?? '획득 조건이 없습니다.',
      imageUrl: data['imageUrl'],
    );
  }
}
