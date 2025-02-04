/// 파일: course_main.dart
/// 목적: 사용자에게 초급, 중급, 코스3를 보여줌
/// 작성자: 박민준
/// 생성일: 2024-12-28
/// 마지막 수정: 2025-01-03 by 강희

import 'package:flutter/material.dart';
import '../../model/section_data.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import 'section.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

/// 코스 섹션을 보여주는 메인 위젯.
/// 현재 보여지는 섹션과 스크롤 동작을 관리하는 로직 포함.
class CourseMain extends StatefulWidget {
  CourseMain({super.key}); // 'const' 제거하여 커스터마이징 가능하도록 설정.

  @override
  State<CourseMain> createState() => _CourseMainState();
}

/// [CourseMain]의 상태 클래스.
/// 섹션 데이터, 스크롤 동작, UI 업데이트를 관리.
class _CourseMainState extends State<CourseMain> {
  /// 화면에 표시할 섹션 데이터 리스트.
  final List<SectionData> data = sectionList;

  /// 현재 화면에 보이는 섹션의 인덱스.
  int iCurrentSection = 0;

  /// UI 요소들의 고정된 높이.
  final heightFirstBox = 0.0;
  final heightSection = 1020.0;

  /// 스크롤 동작을 관리하는 컨트롤러.
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(scrollListener);
  }

  /// 스크롤 이벤트를 감지하고 현재 섹션 인덱스를 업데이트.
  void scrollListener() {
    final currentScroll = scrollCtrl.position.pixels;
    int index = (currentScroll / heightSection).floor();

    if (index < 0) index = 0;

    // index가 data.length - 1보다 커지지 않도록 수정
    if (index >= data.length) index = data.length - 1;

    if (index != iCurrentSection) setState(() => iCurrentSection = index);
  }


  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_Course(), // 코스 화면을 위한 커스텀 앱바.
      body: SafeArea(
        child: Stack(
          children: [
            /// 섹션을 표시하고 스크롤을 처리하는 ListView.
            ListView.separated(
              controller: scrollCtrl,
              itemBuilder: (_, i) => i == 0
                  ? SizedBox(
                height: heightFirstBox,
              )
                  : Section(
                data: data[i - 1],
              ),
              separatorBuilder: (_, i) => SizedBox(
                height: i == 0 ? 0.0 : 0.0,  // First item has 0 height, others have 24 height
              ),
              itemCount: data.length + 1,
            ),
            /// 현재 보이는 섹션을 화면 하단에 표시하는 위젯.
            CurrentSection(data: data[iCurrentSection]),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(), // 커스텀 네비게이션 바.
    );
  }
}

/// 화면 하단에 현재 보이는 섹션을 표시하는 위젯.
class CurrentSection extends StatelessWidget {
  /// 현재 섹션의 데이터.
  final SectionData data;

  const CurrentSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data.section != 0) ...[ // 이걸 1로 바꾸면 상단에 없어짐
                    Text(
                      data.title,
                      style: body_large_semi(context),
                    ),
                    /// 단계와 섹션 번호를 표시.
                    Text(
                      data.sectionDetail,
                      style: body_small(context),
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
