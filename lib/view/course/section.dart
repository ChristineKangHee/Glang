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
  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    } else {
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    }
  }

  /// 스테이지 팝업 표시 함수
  void _showPopup(BuildContext context, int index) {
    final stage = data.stages[index];

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // 뒤쪽 화면도 탭 이벤트가 통과되도록
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 60.0),
                padding: const EdgeInsets.all(20.0),
                child: SectionPopup(
                  title: data.title,              // 코스 제목
                  subTitle: stage.subdetailTitle, // 스테이지 제목
                  time: stage.totalTime,          // 예상 소요 시간
                  level: stage.difficultyLevel,   // 난이도
                  description: stage.textContents,// 설명
                  missions: stage.missions,       // 미션 리스트
                  effects: stage.effects,         // 학습 효과 리스트
                  achievement: stage.achievement.toString(),
                  // 팝업에 상태를 문자열로 넘길 경우
                  status: stageStatusToString(stage.status),
                ),
              ),
            ),
          ],
        );
      },
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
            fit: BoxFit.cover,
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
