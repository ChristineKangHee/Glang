/// File: CR_learning.dart
/// Purpose: 사용자가 표지를 보고 제목을 유추하는 학습 화면 구현
/// Author: 박민준
/// Created: 2025-01-0?
/// Last Modified: 2025-02-05 by 박민준

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import 'package:readventure/view/feature/after_read/widget/custom_chip.dart';
import '../../../../theme/theme.dart';
import '../../after_read/widget/answer_section.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/AlertDialogBR.dart';

class CRLearning extends StatefulWidget {
  const CRLearning({super.key});

  @override
  State<CRLearning> createState() => _CELearningState();
}

class _CELearningState extends State<CRLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  List<String> _keywords = ["#읽기능력","#맞춤형도구","#피드백"];
  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  // 결과창 띄우기
  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialogBR();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_6(
        title: "표지 탐구하기",
        automaticallyImplyLeading: false,
        onIconPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이머와 제목 섹션
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("표지를 보고 제목을 유추해보세요!", style: body_small_semi(context).copyWith(color: customColors.primary),),
                    ),
                    // 본문 텍스트
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        height: 300.h,
                        child: Image.asset("assets/images/cover.png"),
                      ),
                    ),
                    ///TODO CustomChip추가: 키워드 3개
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _keywords
                            .map(
                              (keyword) => CustomChip(
                            label: keyword,
                            customColors: customColors, // CustomColors를 전달
                            borderRadius: 14.0, // 원하는 Radius 값 설정 가능
                          ),
                        )
                            .toList(),
                      ),
                    ),

                    SizedBox(height: 8,),
                    BigDivider(),
                    BigDivider(),
                    SizedBox(height: 8,),
                    // 사용자 입력 영역
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Answer_Section(
                        controller: _controller,
                        customColors: customColors,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 제출 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildButton(customColors),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildButton(CustomColors customColors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isButtonEnabled ? _showAlertDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          disabledBackgroundColor: customColors.primary20,
          disabledForegroundColor: Colors.white,
        ),
        child: const Text("제출하기", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
