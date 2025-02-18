import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import '../../../model/memo_model.dart';
import '../../../model/section_data.dart';
import '../../../model/stage_data.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/memo_notifier.dart';
import '../../components/custom_app_bar.dart';

// 예시: 현재 사용자의 StageData를 Map으로 관리하는 Provider
final stageDataProvider = FutureProvider<Map<String, StageData>>((ref) async {
  // 실제 사용자 ID로 대체 (예: FirebaseAuth.instance.currentUser.uid)
  final String userId = 'currentUserId';
  final stages = await loadStagesFromFirestore(userId);
  return { for (var stage in stages) stage.stageId : stage };
});

class MemoListPage extends ConsumerWidget {
  const MemoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memoProvider);
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '메모'),
      body: memos.isEmpty
          ? Center(
        child: Text(
          "저장된 메모가 없습니다.",
          style: body_small(context).copyWith(color: customColors.neutral60),
        ),
      )
          : ListView.builder(
        itemCount: memos.length,
        itemBuilder: (context, index) {
          final memo = memos[index];
          final formattedDate =
          DateFormat('yyyy.MM.dd').format(memo.createdAt);
          return ListTile(
            title: Text(memo.selectedText),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memo.note),
                const SizedBox(height: 4),
                Text(
                  '원문: ${memo.subdetailTitle}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '생성일: $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(context, ref, memo);
                } else if (value == 'delete') {
                  ref.read(memoProvider.notifier).deleteMemo(memo.id);
                } else if (value == 'view') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextSegmentsPage(
                        stageId: memo.stageId,
                        subdetailTitle: memo.subdetailTitle,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
                PopupMenuItem(value: 'view', child: Text('원문보기')),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showEditDialog(BuildContext context, WidgetRef ref, Memo memo) {
    final controller = TextEditingController(text: memo.note);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모 수정'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '메모를 입력하세요.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final newNote = controller.text.trim();
                if (newNote.isNotEmpty) {
                  await ref.read(memoProvider.notifier).updateMemo(memo.id, newNote);
                }
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}

class TextSegmentsPage extends ConsumerWidget {
  final String stageId;
  final String subdetailTitle;

  const TextSegmentsPage({
    Key? key,
    required this.stageId,
    required this.subdetailTitle, // 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageDataMapAsync = ref.watch(stageDataProvider);
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return stageDataMapAsync.when(
      data: (stageMap) {
        final stageData = stageMap[stageId];
        if (stageData == null) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle), // 변경
            body: const Center(child: Text("해당 스테이지를 찾을 수 없습니다.")),
          );
        }
        final textSegments = stageData.readingData?.textSegments ?? [];
        return Scaffold(
          appBar: CustomAppBar_2depth_4(title: subdetailTitle), // 변경
          body: ListView.builder(
            itemCount: textSegments.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                textSegments[index],
                style: reading_textstyle(context).copyWith(color: customColors.neutral0),
              ),
            ),
          ),
        );
      },
      error: (err, stack) => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle), // 변경
        body: Center(child: Text("오류 발생: $err")),
      ),
      loading: () => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle), // 변경
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

