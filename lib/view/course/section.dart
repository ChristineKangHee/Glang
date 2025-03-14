/// File: section.dart
/// Purpose: 학습 코스(섹션)와 해당 섹션의 스테이지 목록을 표시하는 UI 위젯
/// Author: 박민준
/// Created: 2025-02-03
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/section_data.dart';
import '../../util/box_shadow_styles.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'course_subdetail.dart';
import 'popup_component.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🔹 StageStatus를 enum → 문자열로 변환하는 헬퍼 (중복 피하려면 별도 파일로 분리 가능)
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
  final SectionData data; // 섹션(코스) 데이터

  const Section({super.key, required this.data});

  /// index별 margin 계산 로직 (기존 로직 그대로)
  /// index별 margin 계산 로직 (좌우 마진 뒤집기)
  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      // 기존의 오른쪽 마진 로직을 왼쪽으로 이동
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    } else {
      // 기존의 왼쪽 마진 로직을 오른쪽으로 이동
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    }
  }


  /// 스테이지 팝업 표시 함수
  ///
  /// Scaffold의 persistent bottom sheet를 전체 화면으로 확장한 후,
  /// 배경을 터치하면 dismiss 되도록 GestureDetector를 적용하였습니다.
  void _showPopup(BuildContext context, int index) {
    final stage = data.stages[index];
    PersistentBottomSheetController? sheetController;

    sheetController = Scaffold.of(context).showBottomSheet(
          (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          // 바깥 전체를 감싸는 GestureDetector
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 배경 터치 시 dismiss
              sheetController?.close();
            },
            child: Stack(
              children: [
                // 화면 하단에 팝업 컨텐츠 배치
                Align(
                  alignment: Alignment.bottomCenter,
                  // 내부 컨텐츠에 GestureDetector를 적용하여 터치 이벤트 전파 방지
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      // margin: const EdgeInsets.only(bottom: 60.0),
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

    // 🔸 스테이지 중에서 진행 중(inProgress) 또는 완료(completed)가 하나라도 있으면 활성화
    final bool isAnyStageActiveOrComplete = data.stages.any((stage) =>
    stage.status == StageStatus.inProgress ||
        stage.status == StageStatus.completed);

    // 🔹 코스 제목을 기반으로 SVG 파일명 결정
    String courseImage = '';
    switch (data.title) {
      case '코스1':
        courseImage = 'assets/images/course1.svg';
        break;
      case '코스2':
        courseImage = 'assets/images/course2.svg';
        break;
      case '코스3':
        courseImage = 'assets/images/course3.svg';
        break;
      default:
        courseImage = 'assets/images/default_course.svg'; // 기본값
    }

    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            courseImage,
            fit: BoxFit.fitWidth, // 이미지 크기 변경 방지
            alignment: Alignment.topCenter, // 위쪽 정렬
            colorFilter: isAnyStageActiveOrComplete
                ? null
                : ColorFilter.mode(customColors.neutral90!, BlendMode.saturation), // 비활성화 처리
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 섹션 제목/설명 영역
            Container(
              color: customColors.neutral100,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.title, style: body_large_semi(context)),
                  Text(data.sectionDetail, style: body_small(context)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 🔹 스테이지 목록 표시
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
                  child: StatusButton(
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
