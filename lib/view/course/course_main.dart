/// File: course_main.dart
/// Purpose: 사용자에게 초급, 중급, 고급 코스를 보여주는 메인 화면
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2025-01-03 by 강희 (수정: 위치측정 방식 적용)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/section_data.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'section.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';

/// 코스 섹션을 보여주는 메인 위젯.
/// 현재 보여지는 섹션과 스크롤 동작을 관리하는 로직 포함.
class CourseMain extends StatefulWidget {
  const CourseMain({Key? key}) : super(key: key);

  @override
  State<CourseMain> createState() => _CourseMainState();
}

/// [CourseMain]의 상태 클래스.
/// 섹션 데이터, 스크롤 동작, UI 업데이트를 관리.
class _CourseMainState extends State<CourseMain> {
  /// 화면에 표시할 섹션 데이터 리스트를 담는 Future
  late Future<List<SectionData>> sectionsFuture;

  /// 현재 화면에 보이는 섹션의 인덱스 (스크롤 위치에 따라 결정)
  int iCurrentSection = 0;

  /// 첫 번째 박스(인트로 등) 높이
  final double heightFirstBox = 0.0;

  /// 각 섹션마다 GlobalKey를 할당하여 위치를 측정
  List<GlobalKey> _sectionKeys = [];

  /// 스크롤 동작을 관리하는 컨트롤러
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(scrollListener);

    // 유저 ID를 기반으로 섹션 데이터 로드
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      sectionsFuture = SectionData.loadSections(userId);
    } else {
      // 로그인이 안 된 경우 등, 빈 리스트를 반환하도록 처리
      sectionsFuture = Future.value([]);
    }
  }

  /// 스크롤 이벤트를 감지하고 현재 섹션 인덱스를 업데이트
  void scrollListener() {
    // 임계값(threshold): 화면 상단에서 어느 정도까지 스크롤되면 섹션이 '지나갔다'고 판단할지 결정
    // (필요에 따라 이 값을 조정하세요)
    const double topThreshold = 150.0;

    int newCurrentSection = 0;
    // 각 섹션의 GlobalKey를 통해 위치를 측정합니다.
    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext != null) {
        final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        // offset.dy가 topThreshold보다 작거나 같으면 화면 상단을 지난 것으로 판단
        if (offset.dy <= topThreshold) {
          newCurrentSection = i;
        }
      }
    }
    if (newCurrentSection != iCurrentSection) {
      setState(() {
        iCurrentSection = newCurrentSection;
      });
    }
  }

  @override
  void dispose() {
    scrollCtrl.removeListener(scrollListener);
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: CustomAppBar_Course(),
        body: SafeArea(
          child: FutureBuilder<List<SectionData>>(
            future: sectionsFuture,
            builder: (context, snapshot) {
              // 로딩 중
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // 에러 발생
              if (snapshot.hasError) {
                return Center( // [i18n] 교체
                  child: Text('data_load_failed'.tr(args: [snapshot.error.toString()])),
                );
              }

              // 정상 로딩 완료
              final sections = snapshot.data!;
              if (sections.isEmpty) {
                // 섹션이 하나도 없을 경우
                return Center( // [i18n] 교체
                  child: Text('no_courses_to_show'.tr()),
                );
              }

              // 섹션 개수와 _sectionKeys 길이가 다르면 새로 생성
              if (_sectionKeys.length != sections.length) {
                _sectionKeys = List.generate(sections.length, (_) => GlobalKey());
              }

              // Stack을 써서 하단에 현재 섹션 정보를 겹쳐서 표시
              return Stack(
                children: [
                  // 섹션 목록 표시
                  ListView.separated(
                    controller: scrollCtrl,
                    itemCount: sections.length + 1,
                    separatorBuilder: (_, i) => const SizedBox(height: 0.0),
                    itemBuilder: (_, i) {
                      // 첫 번째 아이템은 빈 박스로 대체
                      if (i == 0) {
                        return SizedBox(height: heightFirstBox);
                      }
                      // 실제 섹션은 i-1 인덱스를 사용하며, 각 섹션에 GlobalKey 부여
                      return Section(
                        key: _sectionKeys[i - 1],
                        data: sections[i - 1],
                      );
                    },
                  ),
                  // 현재 섹션 표시 위젯
                  if (sections.isNotEmpty)
                    CurrentSection(data: sections[iCurrentSection]),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}

/// 화면 하단에 현재 보이는 섹션 정보를 표시하는 위젯
class CurrentSection extends StatelessWidget {
  /// 현재 섹션의 데이터
  final SectionData data;

  const CurrentSection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // section 값이 1 이상인 경우만 표시 (예시)
                  if (data.section >= 1) ...[
                    Text(
                      data.title,
                      style: body_large_semi(context),
                    ),
                    Text(
                      data.sectionDetail,
                      style: body_small(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
