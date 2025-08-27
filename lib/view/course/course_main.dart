/// File: lib/view/course/course_main.dart
/// Purpose: 사용자에게 초급, 중급, 고급 코스를 보여주는 메인 화면
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2025-08-13 by ChatGPT (다국어 + 새 섹션 로딩 구조 적용)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // CHANGED: Riverpod 사용
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/section_data.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'section.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import 'package:easy_localization/easy_localization.dart' hide tr;

// CHANGED: 새 조립/리포지토리 프로바이더
import '../../services/repository_providers.dart';
// CHANGED: tr 유틸
import '../../localization/tr.dart';

/// 코스 섹션을 보여주는 메인 위젯.
/// CHANGED: FutureBuilder 제거 → Riverpod provider 사용
class CourseMain extends ConsumerStatefulWidget {
  const CourseMain({Key? key}) : super(key: key);

  @override
  ConsumerState<CourseMain> createState() => _CourseMainState();
}

class _CourseMainState extends ConsumerState<CourseMain> {
  int iCurrentSection = 0;                 // 현재 화면에 보이는 섹션 인덱스
  final double heightFirstBox = 0.0;       // 첫 박스 높이
  List<GlobalKey> _sectionKeys = [];       // 위치 측정용 키
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(scrollListener);

    // CHANGED: userId는 provider 내부에서 사용됨. 여기서는 인증만 확인.
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // 로그아웃 상태: 별도 처리 없이 provider가 빈 섹션 반환
    }
  }

  void scrollListener() {
    const double topThreshold = 150.0;
    int newCurrentSection = 0;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext != null) {
        final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        if (offset.dy <= topThreshold) {
          newCurrentSection = i;
        }
      }
    }
    if (newCurrentSection != iCurrentSection) {
      setState(() => iCurrentSection = newCurrentSection);
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
    final sectionsAsync = ref.watch(publicSectionsProvider); // CHANGED

    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: CustomAppBar_Course(),
        body: SafeArea(
          child: sectionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Text('data_load_failed'.tr(args: [e.toString()])),
            ),
            data: (sections) {
              if (sections.isEmpty) {
                return Center(child: Text('no_courses_to_show'.tr()));
              }

              if (_sectionKeys.length != sections.length) {
                _sectionKeys = List.generate(sections.length, (_) => GlobalKey());
              }

              return Stack(
                children: [
                  ListView.separated(
                    controller: scrollCtrl,
                    itemCount: sections.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 0.0),
                    itemBuilder: (_, i) {
                      if (i == 0) return SizedBox(height: heightFirstBox);
                      return Section(
                        key: _sectionKeys[i - 1],
                        data: sections[i - 1],
                      );
                    },
                  ),
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
  final SectionData data;
  const CurrentSection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = context.glangLocale; // CHANGED: tr()에 전달

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
                  if (data.section >= 1) ...[
                    Text(
                      tr(data.title, locale),              // CHANGED
                      style: body_large_semi(context),
                    ),
                    Text(
                      tr(data.sectionDetail, locale),      // CHANGED
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
