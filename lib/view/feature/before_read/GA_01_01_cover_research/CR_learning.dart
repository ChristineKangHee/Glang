// lib/view/feature/before_read/GA_01_01_cover_research/CR_learning.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';
import 'package:readventure/view/feature/after_read/widget/custom_chip.dart';
import 'package:readventure/view/feature/after_read/widget/answer_section.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N 추가
import '../../../../model/section_data.dart';
import '../../../../model/stage_data.dart';
import '../../../../theme/theme.dart';
import '../../../home/stage_provider.dart';
import '../widget/AlertDialogBR.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/progress_repository.dart';
import 'package:readventure/localization/tr.dart';

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

  // ✅ 진행도 업데이트 + 결과창: setStageProgress 한 번으로 병합 저장
  Future<void> _onSubmit(StageData stage) async {
    final brData = stage.brData;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("⚠️ 유저가 로그인되지 않음!");
      return;
    }

    // beforeReading만 true로 켜고, status는 inProgress 유지/설정
    await ProgressRepository.instance.setStageProgress(
      uid: userId,
      stageId: stage.stageId,
      data: {
        'status': 'inProgress',
        'activityCompleted': {
          'beforeReading': true, // 나머지 키는 기존 값 유지(merge)
        },
      },
    );

    // 다국어 키워드
    final locale = context.glangLocale;
    final localizedKeywords =
    brData == null ? const <String>[] : trList(brData.keywords, locale);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialogBR(
        answerText: _controller.text,
        coverImageUrl: brData?.coverImageUrl ?? "assets/images/cover.png",
        keywords: localizedKeywords,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final stage = ref.watch(currentStageProvider);
    final brData = stage?.brData;

    final stagesAsync = ref.watch(stagesProvider);
    final uid = ref.watch(userIdProvider);

    final locale = context.glangLocale;
    final keywordList =
    brData == null ? const <String>[] : trList(brData.keywords, locale);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_6(
        title: 'cover_research_title'.tr(), // ✅ L10N
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
                    // 타이틀
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'cover_research_instruction'.tr(), // ✅ L10N
                        style: body_small_semi(context)
                            .copyWith(color: customColors.primary),
                      ),
                    ),
                    // ✅ 표지 이미지: URL/에셋 모두 대응
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        height: 300.h,
                        child: _buildCoverImage(brData?.coverImageUrl),
                      ),
                    ),

                    if (keywordList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: keywordList
                              .map((keyword) => CustomChip(
                            label: keyword,
                            customColors: customColors,
                            borderRadius: 14.0,
                          ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 8),
                    BigDivider(),
                    BigDivider(),
                    const SizedBox(height: 8),
                    // 사용자 입력
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

  // ✅ 표지 이미지 빌더: http/https → 네트워크, 그외 → 에셋
  Widget _buildCoverImage(String? coverImageUrl) {
    if (coverImageUrl == null || coverImageUrl.isEmpty) {
      return Image.asset("assets/images/cover.png", fit: BoxFit.cover);
    }
    final uri = Uri.tryParse(coverImageUrl);
    final isNetwork = uri != null && uri.hasScheme; // http/https/file 등
    if (isNetwork) {
      return Image.network(coverImageUrl, fit: BoxFit.cover);
    }
    // 파일명만 온 경우 에셋 폴더 기준으로 처리 (프로젝트 경로에 맞게 조정)
    return Image.asset("assets/images/$coverImageUrl", fit: BoxFit.cover);
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
        child: Text('submit'.tr(), style: const TextStyle(fontSize: 16)), // ✅ L10N
      ),
    );
  }
}
