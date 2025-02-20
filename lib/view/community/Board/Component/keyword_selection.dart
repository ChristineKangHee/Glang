/// File: keyword_selection.dart
/// Purpose: 에세이 전용 키워드 선택 다이얼로그
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/alarm_dialog.dart';
import '../../../components/custom_app_bar.dart';
import '../Component/taginput_component.dart';
import '../Component/writingform_component.dart';

/// 에세이 전용 키워드 선택 다이얼로그
class KeywordSelectionDialog extends ConsumerStatefulWidget {
  final List<String> keywordList;

  /// 생성자: 키워드 리스트를 받아 초기화
  KeywordSelectionDialog(this.keywordList, {Key? key}) : super(key: key);

  @override
  KeywordSelectionDialogState createState() => KeywordSelectionDialogState();
}

class KeywordSelectionDialogState extends ConsumerState<KeywordSelectionDialog> {
  bool isSpinning = false; // 현재 키워드가 회전 중인지 여부
  bool isStarted = false; // 키워드 선택이 시작되었는지 여부
  int currentIndex = 0; // 현재 선택된 키워드의 인덱스
  String selectedKeyword = ''; // 최종 선택된 키워드
  Timer? _timer; // 키워드 회전을 위한 타이머
  @override
  void initState() {
    super.initState();

    final random = Random();
    currentIndex = random.nextInt(widget.keywordList.length); // 랜덤 인덱스 선택
    selectedKeyword = widget.keywordList[currentIndex]; // 랜덤 키워드 설정
  }
  /// 키워드 회전 시작
  void startSpinning() {
    setState(() {
      isStarted = true;
      isSpinning = true;
    });

    // 일정 간격으로 키워드 변경
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.keywordList.length;
      });
    });

    // 1초 후 키워드 회전 중지 및 최종 선택
    Future.delayed(const Duration(seconds: 1), () {
      _timer?.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = widget.keywordList[currentIndex];
      });
    });
  }

  /// 다이얼로그가 닫힐 때 타이머 해제
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        "랜덤 키워드 뽑기",
        style: body_medium_semi(context),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isStarted) ...[
            Column(
              children: [
                SvgPicture.asset("assets/images/randombox.svg", height: 180),
                const SizedBox(height: 24),
                Text(
                  '뽑기 통을 돌려서\n에세이 주제를 선정해보아요',
                  style: body_small(context).copyWith(color: customColors.neutral30),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ButtonPrimary_noPadding(
                  function: startSpinning,
                  title: '돌리기',
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 124),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.keywordList[currentIndex],
                    style: body_large_semi(context).copyWith(color: customColors.primary),
                    key: ValueKey<int>(currentIndex),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (!isSpinning) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: startSpinning,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: ShapeDecoration(
                          color: customColors.neutral90,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Center(
                          child: Text(
                            '다시 돌리기',
                            textAlign: TextAlign.center,
                            style: body_small_semi(context).copyWith(color: customColors.neutral60),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: selectedKeyword.isEmpty ? null : () => Navigator.of(context).pop(selectedKeyword),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: ShapeDecoration(
                          color: customColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Center(
                          child: Text(
                            '작성하기',
                            textAlign: TextAlign.center,
                            style: body_small_semi(context).copyWith(color: customColors.neutral100),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ]
        ],
      ),
      backgroundColor: customColors.neutral100,
    );
  }
}