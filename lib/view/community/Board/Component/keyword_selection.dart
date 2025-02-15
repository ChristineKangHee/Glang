import 'dart:async';
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

// 에세이 전용 키워드 선택 다이얼로그
class KeywordSelectionDialog extends ConsumerStatefulWidget {
  final List<String> keywordList;
  KeywordSelectionDialog(this.keywordList);

  @override
  KeywordSelectionDialogState createState() => KeywordSelectionDialogState();
}

class KeywordSelectionDialogState extends ConsumerState<KeywordSelectionDialog> {
  bool isSpinning = false;
  bool isStarted = false;
  int currentIndex = 0;
  String selectedKeyword = '';
  Timer? _timer;

  void startSpinning() {
    setState(() {
      isStarted = true;
      isSpinning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 80), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.keywordList.length;
      });
    });

    Future.delayed(Duration(seconds: 1), () {
      _timer?.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = widget.keywordList[currentIndex];
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
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
                SizedBox(height: 24),
                Text(
                  '뽑기 통을 돌려서\n에세이 주제를 선정해보아요',
                  style: body_small(context).copyWith(color: customColors.neutral30),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ButtonPrimary_noPadding(
                  function: startSpinning,
                  title: '돌리기',
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 124),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 100),
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
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: selectedKeyword.isEmpty ? null : () => Navigator.of(context).pop(selectedKeyword),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
