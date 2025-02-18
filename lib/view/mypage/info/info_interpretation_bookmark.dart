import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/section_data.dart'; // 필요에 따라 경로 수정
import '../../components/custom_app_bar.dart';
import 'memo_list_page.dart';

// BookmarksPage를 MemoListPage와 유사하게 ConsumerWidget 대신 StatelessWidget으로 구현
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("로그인이 필요합니다."));
    }

    // 사용자 문서 내부의 서브컬렉션 'bookmarks'를 구독합니다.
    final bookmarksQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '해석'),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookmarksQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("저장된 해석이 없습니다."));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bool isSentence = data['type'] == 'sentence';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['selectedText'] ?? ''),
                  subtitle: isSentence
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['subdetailTitle'] ?? ''),
                      const SizedBox(height: 4),
                      Text("문맥상 의미: ${data['contextualMeaning'] ?? ''}"),
                      Text("요약: ${data['summary'] ?? ''}"),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['subdetailTitle'] ?? ''),
                      const SizedBox(height: 4),
                      Text("Dictionary Meaning: ${data['dictionaryMeaning'] ?? ''}"),
                      Text("Contextual Meaning: ${data['contextualMeaning'] ?? ''}"),
                      Text(
                        "Synonyms: ${data['synonyms'] is List ? (data['synonyms'] as List).join(', ') : data['synonyms'] ?? ''}",
                      ),
                      Text(
                        "Antonyms: ${data['antonyms'] is List ? (data['antonyms'] as List).join(', ') : data['antonyms'] ?? ''}",
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.article),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TextSegmentsPage(
                                stageId: data['stageId'],
                                subdetailTitle: data['subdetailTitle'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await docs[index].reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("해당 해석이 삭제되었습니다.")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
