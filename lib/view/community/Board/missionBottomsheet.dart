import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../viewmodel/custom_colors_provider.dart';

class CourseSelectionBottomSheet extends ConsumerStatefulWidget {
  @override
  _CourseSelectionBottomSheetState createState() =>
      _CourseSelectionBottomSheetState();
}

final Map<String, String> missionContents = {
  '미션 1-1-1': '미션 1-1-1에 관련된 내용입니다.',
  '미션 1-1-2': '미션 1-1-2에 관련된 내용입니다.',
  '미션 1-2-1': '미션 1-2-1에 관련된 내용입니다.',
  '미션 1-2-2': '미션 1-2-2에 관련된 내용입니다.',
  '미션 2-1-1': '미션 2-1-1에 관련된 내용입니다.',
  '미션 2-1-2': '미션 2-1-2에 관련된 내용입니다.',
  '미션 2-2-1': '미션 2-2-1에 관련된 내용입니다.',
  '미션 2-2-2': '미션 2-2-2에 관련된 내용입니다.',
};

class _CourseSelectionBottomSheetState extends ConsumerState<CourseSelectionBottomSheet> {
  String? selectedCourse;
  String? selectedStage;
  String? selectedMission;

  final Map<String, List<String>> courses = {
    '코스 1': ['스테이지 1-1', '스테이지 1-2'],
    '코스 2': ['스테이지 2-1', '스테이지 2-2'],
  };

  final Map<String, List<String>> stages = {
    '스테이지 1-1': ['미션 1-1-1', '미션 1-1-2'],
    '스테이지 1-2': ['미션 1-2-1', '미션 1-2-2'],
    '스테이지 2-1': ['미션 2-1-1', '미션 2-1-2'],
    '스테이지 2-2': ['미션 2-2-1', '미션 2-2-2'],
  };

  void resetSelection() {
    setState(() {
      selectedCourse = null;
      selectedStage = null;
      selectedMission = null;
    });
  }

  void goBack() {
    setState(() {
      if (selectedMission != null) {
        selectedMission = null;
      } else if (selectedStage != null) {
        selectedStage = null;
      } else if (selectedCourse != null) {
        selectedCourse = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    double bottomSheetHeight = screenHeight / 2;

    return Container(
      padding: EdgeInsets.all(16),
      height: bottomSheetHeight,
      decoration: BoxDecoration(
        color: customColors.neutral100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (selectedCourse != null || selectedStage != null)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: goBack,
                )
              else
                SizedBox(width: 48), // IconButton이 없을 때 동일한 공간 차지
              Expanded(
                child: Text(
                  '미션 글 불러오기',
                  // selectedCourse == null
                  //     ? '코스를 선택하세요'
                  //     : selectedStage == null
                  //     ? '스테이지를 선택하세요'
                  //     : '미션을 선택하세요',
                  textAlign: TextAlign.center, // 중앙 정렬
                  style: body_small_semi(context),
                ),
              ),
              SizedBox(width: 48), // 오른쪽 여백을 맞추기 위해 추가
            ],
          ),

          SizedBox(height: 8,),
          Expanded(
            child: ListView.builder(
              itemCount: selectedCourse == null
                  ? courses.keys.length
                  : selectedStage == null
                  ? courses[selectedCourse]!.length
                  : stages[selectedStage]!.length,
              itemBuilder: (context, index) {
                final item = selectedCourse == null
                    ? courses.keys.elementAt(index)
                    : selectedStage == null
                    ? courses[selectedCourse]![index]
                    : stages[selectedStage]![index];

                return selectedStage == null ?
                Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item, style: body_medium_semi(context)),
                          Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30,),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedCourse == null) {
                            selectedCourse = item;
                          } else {
                            selectedStage = item;
                          }
                        });
                      },
                    ),
                    Divider(color: customColors.neutral80,),
                  ],
                ) :
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: ShapeDecoration(
                    color: customColors.neutral100,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: customColors.neutral80!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item,
                              style: body_medium_semi(context).copyWith(color: customColors.primary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              missionContents[item] ?? '',
                              style: body_xsmall(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedCourse == null) {
                              selectedCourse = item;
                            } else if (selectedStage == null) {
                              selectedStage = item;
                            } else {
                              selectedMission = item;
                              Navigator.pop(context, selectedMission);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: customColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '선택하기',
                            style: body_xsmall_semi(context).copyWith(color: customColors.neutral100),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCourseSelectionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return CourseSelectionBottomSheet();
    },
  );
}
