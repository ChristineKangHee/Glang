import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/section_data.dart';
import '../view/home/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final sectionProvider = FutureProvider<List<SectionData>>((ref) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? userId = _auth.currentUser?.uid;

  if (userId == null) {
    return []; // 유저가 없으면 빈 리스트 반환
  }

  return await SectionData.loadSections(userId);
});
