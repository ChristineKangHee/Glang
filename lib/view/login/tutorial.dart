// 이 파일은 튜토리얼 화면을 구성하는 위젯들을 포함하고 있습니다.
// 작성자: 강희
// 작성일: 2025-02-20
// 수정 이력: 없음

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:readventure/viewmodel/app_state_controller.dart';
import '../../theme/theme.dart';
import '../components/custom_button.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import '../../services/progress_seeder.dart'; // 파일 위치에 맞게 경로 조정

// TutorialScreen 클래스는 튜토리얼 페이지를 보여주는 화면을 구성합니다.
class TutorialScreen extends ConsumerStatefulWidget { // ✅ 변경
  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState(); // ✅ 변경
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: TutorialPageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _currentPage = page),
                // 🔽 onStart에 ref를 넘겨서 uid를 provider에서 읽도록 함
                onStart: () async {
                  final uid = ref.read(appStateProvider)?.uid; // ✅ 전역 상태에서 uid
                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인이 필요합니다.')),
                    );
                    return;
                  }

                  // 진행 시드
                  await ProgressSeeder.seedUserProgressAfterTutorial(uid);

                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ),
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: WormEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    spacing: 10,
                    dotColor: customColors.primary20!,
                    activeDotColor: customColors.primary!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// TutorialPageView 클래스는 각 튜토리얼 페이지를 관리합니다.
class TutorialPageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final Future<void> Function()? onStart; // ✅ 추가

  TutorialPageView({
    required this.controller,
    required this.onPageChanged,
    this.onStart, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      onPageChanged: onPageChanged,
      children: [
        TutorialPage(
          title: '맞춤 코스로\n몰입형 읽기 경험!',
          content: '책 읽기 전, 중, 후 미션과\n읽기 목표를 수행하며 몰입형 독서를 즐겨요',
          image: 'assets/images/tutorial1.png',
        ),
        TutorialPage(
          title: 'AI 피드백으로\n성장 포인트 점검!',
          content: '강점과 개선점을 바로 확인해요',
          image: 'assets/images/tutorial2.png',
        ),
        TutorialPage(
          title: '읽기 패턴 분석으로\n성장을 한눈에!',
          content: '리포트를 통해 성취도를 시각적으로 확인하세요',
          image: 'assets/images/tutorial3.png',
        ),
        TutorialPage(
          title: '배지와 커뮤니티로\n읽기의 재미 UP!',
          content: '미션 완료로 배지를 획득하고,\n커뮤니티에 글을 공유하며 함께 성장하세요',
          image: 'assets/images/tutorial4.png',
          showStartButton: true,
          onStart: onStart, // ✅ 전달
        ),
      ],
    );
  }
}


// TutorialPage 클래스는 각 튜토리얼 페이지의 내용을 구성합니다.
class TutorialPage extends StatelessWidget {
  final String title;
  final String content;
  final String image;
  final bool showStartButton; // '시작하기' 버튼 표시 여부
  final Future<void> Function()? onStart; // ✅ 추가

  TutorialPage({
    required this.title,
    required this.content,
    required this.image,
    this.showStartButton = false,
    this.onStart, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 커스텀 색상 정보 가져오기
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            Text(
              title, // 제목 표시
              style: heading_large(context).copyWith(color: customColors.primary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              content, // 내용 표시
              style: body_small(context).copyWith(color: customColors.neutral60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: 16),
        ClipRRect(
          child: Image.asset(
            image, // 이미지 표시
            width: screenWidth,
            height: screenWidth * 1.2,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        if (showStartButton) // '시작하기' 버튼이 있을 경우
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),  // 버튼 하단 패딩
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ButtonPrimary(
                function: () async {
                  if (onStart != null) {
                    await onStart!(); // ✅ 외부에서 주입된 onStart 실행
                  } else {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                title: '시작하기', // 버튼 제목
              ),
            ),
          ),
      ],
    );
  }
}
