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

/// 예시: 현재 사용자의 StageData를 Map으로 관리하는 Provider
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
          final formattedDate = DateFormat('yyyy.MM.dd').format(memo.createdAt);
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
            // 기존 PopupMenuButton 대신 IconButton를 사용하여 바텀시트 호출
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showMemoActionBottomSheet(context, memo, customColors, ref);
              },
            ),
          );
        },
      ),
    );
  }
}

/// 바텀시트를 호출하는 헬퍼 함수
void showMemoActionBottomSheet(
    BuildContext context, Memo memo, CustomColors customColors, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    builder: (context) => MemoActionBottomSheet(
      memo: memo,
      customColors: customColors,
      ref: ref,
      parentContext: context,
    ),
  );
}

/// Memo에 대한 액션(수정, 삭제, 원문보기)을 보여주는 바텀시트 위젯
class MemoActionBottomSheet extends StatelessWidget {
  final Memo memo;
  final CustomColors customColors;
  final WidgetRef ref;
  final BuildContext parentContext;

  const MemoActionBottomSheet({
    Key? key,
    required this.memo,
    required this.customColors,
    required this.ref,
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
            // 메모 수정
            ListTile(
              title: Center(child: Text('수정', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                final controller = TextEditingController(text: memo.note);
                showDialog(
                  context: parentContext,
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
              },
            ),
            const SizedBox(height: 10),
            // 원문보기
            ListTile(
              title: Center(child: Text('원문보기', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => TextSegmentsPage(
                      stageId: memo.stageId,
                      subdetailTitle: memo.subdetailTitle,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 메모 삭제
            ListTile(
              title: Center(child: Text('삭제', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                ref.read(memoProvider.notifier).deleteMemo(memo.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TextSegmentsPage extends ConsumerWidget {
  final String stageId;
  final String subdetailTitle;

  const TextSegmentsPage({
    Key? key,
    required this.stageId,
    required this.subdetailTitle,
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
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(child: Text("해당 스테이지를 찾을 수 없습니다.")),
          );
        }
        final textSegments = stageData.readingData?.textSegments ?? [];
        return Scaffold(
          appBar: CustomAppBar_2depth_4(title: subdetailTitle),
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
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: Center(child: Text("오류 발생: $err")),
      ),
      loading: () => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
