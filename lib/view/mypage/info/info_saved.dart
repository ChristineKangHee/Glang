/// File: saved.dart
/// Purpose: 저장한 문장과 단어,질문들을 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-24 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class InfoSaved extends ConsumerWidget {
  const InfoSaved({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return DefaultTabController(
      length: 2, // 탭의 개수 (저장된 단어, 저장된 문장)
      child: Scaffold(
        appBar: CustomAppBar_2depth_4(
          title: "저장",
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.onSecondary,
            labelStyle: pretendardSemiBold(context).copyWith(fontSize: 16),
            tabs: [
              Tab(text: "저장된 단어"), // 첫 번째 탭
              Tab(text: "저장된 문장"), // 두 번째 탭
            ],
          ),
        ),
        body: SavedWidget(),
      ),
    );
  }
}

class SavedWidget extends StatefulWidget {
  @override
  _SavedWidgetState createState() => _SavedWidgetState();
}

class _SavedWidgetState extends State<SavedWidget> {
  bool isQuestionIncluded = false; // 체크박스 상태 관리
  String selectedFilter = '최신순'; // 필터링 상태 관리

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 69,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isQuestionIncluded = !isQuestionIncluded;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isQuestionIncluded
                              ? customColors.primary!
                              : customColors.neutral80!,
                          width: 2,
                        ),
                        color: isQuestionIncluded
                            ? customColors.primary
                            : Colors.transparent,
                      ),
                      child: isQuestionIncluded
                          ? Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '질문 포함',
                    style: body_xsmall(context),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: '최신순',
                    child: Text('최신순'),
                  ),
                  const PopupMenuItem<String>(
                    value: '가나다순',
                    child: Text('가나다순'),
                  ),
                ],
                child: Container(
                  width: 120,
                  height: 37,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: customColors.neutral80!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedFilter,
                        style: body_xsmall(context).copyWith(color: customColors.neutral30),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: customColors.neutral30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              // 저장된 단어 탭 내용
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '저장된 단어',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: customColors.primary!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '단어 목록이 여기에 표시됩니다.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 저장된 문장 탭 내용
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '저장된 문장',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: customColors.neutral80!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '문장 목록이 여기에 표시됩니다.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
