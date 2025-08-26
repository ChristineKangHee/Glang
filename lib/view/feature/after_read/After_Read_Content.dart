// lib/view/feature/after_read/After_Read_Content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'package:readventure/theme/theme.dart';
import '../../../../theme/font.dart';
import '../../components/custom_app_bar.dart';

import 'package:readventure/model/stage_data.dart';
import 'package:readventure/view/home/stage_provider.dart';     // ✅ 새 provider
import 'package:readventure/util/locale_text.dart';             // ✅ llx 헬퍼 (LocalizedList → List<String>)

// NOTE: 불필요했던 import 제거
// import 'package:readventure/view/feature/reading/quiz_data.dart';
// import '../../mypage/info/memo_list_page.dart';

class AfterReadContent extends ConsumerWidget {
  final String stageId;
  final String subdetailTitle; // 호출부에서 String을 넘기고 있으므로 그대로 사용

  const AfterReadContent({
    Key? key,
    required this.stageId,
    required this.subdetailTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final stagesAsync = ref.watch(stagesProvider); // ✅ 모든 스테이지(마스터+진행 오버레이)

    return stagesAsync.when(
      loading: () => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: Center(child: Text('오류 발생: $error')),
      ),
      data: (stages) {
        final StageData? stageData =
        stages.firstWhereOrNull((s) => s.stageId == stageId);

        if (stageData == null) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(child: Text("해당 코스를 찾을 수 없습니다.")),
          );
        }

        // ✅ LocalizedList → List<String> (언어 폴백 포함)
        final segs = (stageData.readingData == null)
            ? const <String>[]
            : llx(context, stageData.readingData!.textSegments);

        if (segs.isEmpty) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(child: Text("표시할 본문이 없습니다.")),
          );
        }

        return Scaffold(
          appBar: CustomAppBar_2depth_4(title: subdetailTitle),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: segs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  segs[index],
                  style: reading_textstyle(context)
                      .copyWith(color: customColors.neutral0),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
