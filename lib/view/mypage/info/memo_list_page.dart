// lib/view/mypage/info/memo_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../model/memo_model.dart';
import '../../../model/stage_data.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/memo_notifier.dart';
import '../../components/custom_app_bar.dart';

// CHANGED: 섹션 마스터 제거 → stage repo만 사용
import '../../../services/stage_repository.dart';
import '../../../services/learning_assembly_service.dart';

// CHANGED: 다국어 유틸
import '../../../localization/tr.dart';

/// 사용자의 StageData를 Map(stageId->StageData)로 제공
final stageDataProvider = FutureProvider<Map<String, StageData>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {};

  // (선택) 스테이지 마스터 프리로드
  await StageRepository.instance.getAllStagesOnce();

  // 섹션 마스터 없이 stages만으로 섹션 조립
  final sections = await LearningAssemblyService.instance.buildPublicSections();

  // 섹션 → 스테이지 평탄화 후 Map으로
  final stages = sections.expand((s) => s.stages);
  return {for (final st in stages) st.stageId: st};
});

class MemoListPage extends ConsumerWidget {
  const MemoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memoProvider);
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      backgroundColor: customColors.neutral90,
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

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: customColors.neutral100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '<${memo.subdetailTitle}>',
                    style: body_xsmall(context).copyWith(color: customColors.neutral60),
                  ),
                  const SizedBox(height: 8),

                  // Selected Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          memo.selectedText,
                          style: body_medium_semi(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: customColors.neutral30),
                        onPressed: () {
                          showMemoActionBottomSheet(context, memo, customColors, ref);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Memo label and note
                  Text("메모", style: body_xsmall_semi(context)),
                  const SizedBox(height: 4),
                  Text(memo.note, style: body_small(context)),
                  const SizedBox(height: 12),

                  // Date
                  Text(
                    formattedDate,
                    style: body_xsmall(context).copyWith(color: customColors.neutral60),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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
    final locale = context.glangLocale;

    return stageDataMapAsync.when(
      data: (stageMap) {
        final stageData = stageMap[stageId];
        if (stageData == null) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(child: Text("해당 스테이지를 찾을 수 없습니다.")),
          );
        }

        // 다국어 텍스트 세그먼트
        final segments = stageData.readingData != null
            ? trList(stageData.readingData!.textSegments, locale)
            : const <String>[];

        return Scaffold(
          appBar: CustomAppBar_2depth_4(title: subdetailTitle),
          body: ListView.builder(
            itemCount: segments.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                segments[index],
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
