import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import 'package:readventure/view/feature/after_read/widget/custom_chip.dart';
import 'package:readventure/view/feature/after_read/widget/answer_section.dart';
import '../../../../model/section_data.dart';
import '../../../../model/stage_data.dart';
import '../../../../theme/theme.dart';
import '../../../home/stage_provider.dart';
import '../widget/AlertDialogBR.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRLearning extends ConsumerStatefulWidget {
  const CRLearning({super.key});

  @override
  ConsumerState<CRLearning> createState() => _CRLearningState();
}

class _CRLearningState extends ConsumerState<CRLearning> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;


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

  // 진행도 업데이트 + 결과창
  Future<void> _onSubmit(StageData stage) async {
    final brData = stage.brData;
    // 실제 유저 ID 가져오기
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    await completeActivityForStage(
      userId: userId,
      stageId: stage.stageId,
      activityType: 'beforeReading',
    );

    // 결과 다이얼로그 띄우기
    // 예시: 사용자가 제출 버튼을 누른 후
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialogBR(
        answerText: _controller.text,
        coverImageUrl: brData?.coverImageUrl ?? "assets/images/cover.png",
        keywords: brData?.keywords ?? [],
      ),
    );

  }


  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final stage = ref.watch(currentStageProvider);
    final brData = stage?.brData;

    print("[CRLearning] selectedStageId = ${ref.watch(selectedStageIdProvider)}");
    print("[CRLearning] stage = $stage"); // stage가 null이면 여기서 확인 가능
    print("[CRLearning] brData = ${stage?.brData}");

    final stagesAsync = ref.watch(stagesProvider);
    print("[CRLearning] stagesProvider: ${stagesAsync.value?.map((s) => s.stageId).toList()}");

    final uid = ref.watch(userIdProvider);
    print("[CRLearning] userId = $uid");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_6(
        title: "표지 탐구하기",
        automaticallyImplyLeading: false,
        onIconPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
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
                      child: Text(
                        "표지를 보고 제목을 유추해보세요!",
                        style: body_small_semi(context).copyWith(color: customColors.primary),
                      ),
                    ),
                    // 표지 이미지
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        height: 300.h,
                        child: brData?.coverImageUrl != null
                            ? Image.network(brData!.coverImageUrl)
                            : Image.asset("assets/images/cover.png"),
                      ),
                    ),
                    // 키워드 표시
                    if (brData?.keywords != null && brData!.keywords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: brData.keywords.map(
                                (keyword) => CustomChip(
                              label: keyword,
                              customColors: customColors,
                              borderRadius: 14.0,
                            ),
                          ).toList(),
                        ),
                      ),
                    const SizedBox(height: 8),
                    BigDivider(),
                    BigDivider(),
                    const SizedBox(height: 8),
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
              child: buildButton(customColors, stage),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildButton(CustomColors customColors, StageData? stage) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isButtonEnabled && stage != null ? () => _onSubmit(stage) : null,
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
