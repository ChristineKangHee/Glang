// info_interpretation_bookmark.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/section_data.dart'; // 필요에 따라 경로 수정
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'memo_list_page.dart';
import '../../../theme/font.dart'; // body_large 등 텍스트 스타일 관련
import 'package:intl/intl.dart'; // 날짜 형식을 위해 필요

// 날짜 변환 함수 추가
String formatDate(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final dateTime = timestamp.toDate(); // Timestamp를 DateTime으로 변환
  return DateFormat('yyyy.MM.dd').format(dateTime);
}


// BookmarksPage를 ConsumerWidget으로 변경하여 ref 사용
class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("로그인이 필요합니다."));
    }

    // 사용자의 bookmarks 서브컬렉션 구독
    final bookmarksQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true);

    // MemoListPage와 같이 customColors 사용 (custom_colors_provider 참고)
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_4(title: '해석'),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookmarksQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("저장된 해석이 없습니다.", style: body_small(context).copyWith(color: customColors.neutral60),));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bool isSentence = data['type'] == 'sentence';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 요소를 양 끝에 정렬
                    children: [
                      Expanded( // 줄바꿈 시 텍스트가 잘 보이게 하기 위함
                        child: Text(
                          '<${data['subdetailTitle']}>' ?? '',
                          style: body_xsmall(context).copyWith(color: customColors.neutral60),
                          overflow: TextOverflow.ellipsis, // 텍스트가 길면 생략 표시
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: customColors.neutral30),
                        onPressed: () {
                          showBookmarkActionBottomSheet(
                            context: context,
                            data: data,
                            docReference: docs[index].reference,
                            customColors: customColors,
                            parentContext: context,
                          );
                        },
                      ),
                    ],
                  ),
                  subtitle: isSentence
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(data['selectedText'] ?? '', style: body_medium_semi(context)),
                      const SizedBox(height: 8),
                      Text("문맥상 의미", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['contextualMeaning'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text("요약", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['summary'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text(formatDate(data['createdAt']), style: body_xsmall(context).copyWith(color: customColors.neutral60)),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(data['selectedText'] ?? '', style: body_medium_semi(context)),
                      const SizedBox(height: 8),
                      Text("사전적 의미", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['dictionaryMeaning'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text("문맥상 의미", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['contextualMeaning'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text("유사어", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['synonyms'] is List ? (data['synonyms'] as List).join(', ') : data['synonyms'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text("반의어", style: body_xsmall_semi(context)),
                      const SizedBox(height: 4),
                      Text(data['antonyms'] is List ? (data['antonyms'] as List).join(', ') : data['antonyms'] ?? '', style: body_small(context)),
                      const SizedBox(height: 8),
                      Text(formatDate(data['createdAt']), style: body_xsmall(context).copyWith(color: customColors.neutral60)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// BookmarksPage에서 사용할 액션 바텀시트를 호출하는 함수
void showBookmarkActionBottomSheet({
  required BuildContext context,
  required Map<String, dynamic> data,
  required DocumentReference docReference,
  required CustomColors customColors,
  required BuildContext parentContext,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => BookmarkActionBottomSheet(
      data: data,
      docReference: docReference,
      customColors: customColors,
      parentContext: parentContext,
    ),
  );
}

/// Bookmarks에 대한 액션(원문보기, 삭제)을 제공하는 바텀시트 위젯
class BookmarkActionBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final DocumentReference docReference;
  final CustomColors customColors;
  final BuildContext parentContext;

  const BookmarkActionBottomSheet({
    Key? key,
    required this.data,
    required this.docReference,
    required this.customColors,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 원문보기: TextSegmentsPage로 이동
            ListTile(
              title: Center(child: Text('원문보기', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => TextSegmentsPage(
                      stageId: data['stageId'],
                      subdetailTitle: data['subdetailTitle'],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // 삭제: 해당 문서를 삭제하고 SnackBar 표시
            ListTile(
              title: Center(child: Text('삭제', style: body_large(context))),
              onTap: () async {
                Navigator.pop(context);
                await docReference.delete();
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text("해당 해석이 삭제되었습니다.")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
