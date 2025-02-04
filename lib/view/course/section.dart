import 'package:flutter/material.dart';
import '../../model/section_data.dart';
import '../../util/box_shadow_styles.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'course_subdetail.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'popup_component.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Section extends ConsumerWidget {
  final SectionData data; // 섹션 데이터

  const Section({super.key, required this.data});

  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    } else {
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    }
  }

  void _showPopup(BuildContext context, int index) {
    final stage = data.stages[index]; // 🔹 StageData 객체 직접 사용
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // 뒤쪽 화면이 클릭 가능하도록 설정
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
                  title: data.title, // 코스 제목
                  subTitle: stage.subdetailTitle, // 스테이지 제목
                  time: stage.totalTime, // 예상 소요 시간
                  level: stage.difficultyLevel, // 난이도
                  description: stage.textContents, // 설명
                  missions: stage.missions, // 미션 리스트
                  effects: stage.effects, // 학습 효과 리스트
                  achievement: stage.achievement, // 성취도
                  status: stage.status, // 상태 (시작 가능, 잠김 등)
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
    return Container(
      color: data.stages.any((stage) =>
      stage.status.contains('start') || stage.status.contains('completed'))
          ? customColors.primary10
          : customColors.neutral90, // Conditionally set color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: customColors.neutral100,
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.title, style: body_large_semi(context)), // 코스 제목
                Text(data.sectionDetail, style: body_small(context)), // 코스 설명
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          ...List.generate(
            data.stages.length, // 🔹 `stages` 리스트 기반으로 반복
                (i) {
              final stage = data.stages[i]; // 🔹 `StageData` 객체 참조
              return Container(
                margin: EdgeInsets.only(
                  bottom: i != data.stages.length - 1 ? 24.0 : 0,
                  left: _getMargin(i),
                  right: _getMargin(i, isLeft: false),
                ),
                child: StatusButton(
                  status: stage.status, // 🔹 `stage` 객체에서 상태 가져오기
                  onPressed: () => _showPopup(context, i),
                ),
              );
            },
          ),
          const SizedBox(height: 24,),
        ],
      ),
    );
  }
}
