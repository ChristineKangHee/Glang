import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/theme.dart';
import '../components/custom_button.dart';
import '../widgets/DoubleBackToExitWrapper.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
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
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            ),
            // SmoothPageIndicator는 마지막 페이지에서만 숨김
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

class TutorialPageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  TutorialPageView({required this.controller, required this.onPageChanged});

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
          showStartButton: true, // 버튼 표시 여부 추가
        ),
      ],
    );
  }
}

class TutorialPage extends StatelessWidget {
  final String title;
  final String content;
  final String image;
  final bool showStartButton;

  TutorialPage({
    required this.title,
    required this.content,
    required this.image,
    this.showStartButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            Text(
              title,
              style: heading_large(context).copyWith(color: customColors.primary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              content,
              style: body_small(context).copyWith(color: customColors.neutral60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: 16),
        ClipRRect(
          child: Image.asset(
            image,
            width: screenWidth,
            height: screenWidth * 1.2,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        if (showStartButton)
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),  // Adds padding to the bottom
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ButtonPrimary(
                function: () {
                  print("시작하기 버튼이 눌렸습니다!");
                  Navigator.pushReplacementNamed(context, '/');
                },
                title: '시작하기',
              ),
            ),
          ),
      ],
    );
  }
}
