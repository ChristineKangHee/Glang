import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../model/stage_data.dart';
import '../../mypage/info/memo_list_page.dart';

class AfterReadContent extends ConsumerWidget {
  final String stageId;
  final String subdetailTitle;

  const AfterReadContent({
    Key? key,
    required this.stageId,
    required this.subdetailTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final stageDataMapAsync = ref.watch(stageDataProvider);

    return stageDataMapAsync.when(
      data: (stageMap) {
        final stageData = stageMap[stageId];
        if (stageData == null) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(
              child: Text("해당 코스를 찾을 수 없습니다."),
            ),
          );
        }

        final textSegments = stageData.readingData?.textSegments ?? [];

        if (textSegments.isEmpty) {
          return Scaffold(
            appBar: CustomAppBar_2depth_4(title: subdetailTitle),
            body: const Center(
              child: Text("표시할 본문이 없습니다."),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar_2depth_4(title: subdetailTitle),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: textSegments.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  textSegments[index],
                  style: reading_textstyle(context).copyWith(color: customColors.neutral0),
                ),
              );
            },
          ),
        );
      },
      loading: () => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar_2depth_4(title: subdetailTitle),
        body: Center(
          child: Text('오류 발생: $error'),
        ),
      ),
    );
  }
}
