/// File: lib/view/course/section.dart
/// Last Modified: 2025-08-13 by ChatGPT (다국어 + 이미지 선택 로직, StatusButton 참조 유지)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/section_data.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../../../theme/font.dart';
import 'package:flutter_svg/flutter_svg.dart';

// CHANGED: tr 유틸
import '../../localization/tr.dart';
import '../../model/stage_data.dart'; // StageStatus
import 'popup_component.dart';       // <-- StatusButton, SectionPopup 여기서 제공

String stageStatusToString(StageStatus status) {
  switch (status) {
    case StageStatus.locked:
      return 'locked';
    case StageStatus.inProgress:
      return 'inProgress';
    case StageStatus.completed:
      return 'completed';
  }
}

class Section extends ConsumerWidget {
  final SectionData data;
  const Section({super.key, required this.data});

  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    } else {
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    }
  }

  void _showPopup(BuildContext context, int index) {
    final stage = data.stages[index];
    PersistentBottomSheetController? sheetController;

    sheetController = Scaffold.of(context).showBottomSheet(
          (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => sheetController?.close(),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: SectionPopup(stage: stage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final locale = context.glangLocale;

    final bool isAnyStageActiveOrComplete = data.stages.any(
          (s) => s.status == StageStatus.inProgress || s.status == StageStatus.completed,
    );

    // CHANGED: 섹션 번호 기반 이미지 선택 (다국어와 무관)
    String courseImage;
    switch (data.section) {
      case 1:
        courseImage = 'assets/images/course1.svg';
        break;
      case 2:
        courseImage = 'assets/images/course2.svg';
        break;
      case 3:
        courseImage = 'assets/images/course3.svg';
        break;
      default:
        courseImage = 'assets/images/default_course.svg';
    }

    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            courseImage,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            colorFilter: isAnyStageActiveOrComplete
                ? null
                : ColorFilter.mode(customColors.neutral90!, BlendMode.saturation),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 섹션 제목/설명
            Container(
              color: customColors.neutral100,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr(data.title, locale), style: body_large_semi(context)),
                  Text(tr(data.sectionDetail, locale), style: body_small(context)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 스테이지 목록
            ...List.generate(
              data.stages.length,
                  (i) {
                final stage = data.stages[i];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: i != data.stages.length - 1 ? 24.0 : 0,
                    left: _getMargin(i),
                    right: _getMargin(i, isLeft: false),
                  ),
                  child: StatusButton( // <-- popup_component.dart에 복구됨
                    status: stageStatusToString(stage.status),
                    onPressed: () => _showPopup(context, i),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }
}
