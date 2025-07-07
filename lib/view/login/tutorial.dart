// 이 파일은 튜토리얼 화면을 구성하는 위젯들을 포함하고 있습니다.
// 작성자: 강희
// 작성일: 2025-02-20
// 수정 이력: 없음

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/theme.dart';
import '../components/custom_button.dart';
import '../widgets/DoubleBackToExitWrapper.dart';

// TutorialScreen 클래스는 튜토리얼 페이지를 보여주는 화면을 구성합니다.
class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController(); // 페이지 전환을 위한 컨트롤러
  int _currentPage = 0; // 현재 페이지를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!; // 커스텀 색상 정보 가져오기
    return DoubleBackToExitWrapper( // 뒤로가기 두 번으로 앱 종료 처리
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: TutorialPageView( // 튜토리얼 페이지들을 보여주는 위젯
                controller: _controller,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page; // 페이지가 변경될 때마다 상태 업데이트
                  });
                },
              ),
            ),
            // 마지막 페이지에서만 SmoothPageIndicator 숨김
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 4, // 페이지 수
                  effect: WormEffect( // 페이지 인디케이터 스타일
                    dotWidth: 10,
                    dotHeight: 10,
                    spacing: 10,
                    dotColor: customColors.primary20!, // 비활성 인디케이터 색상
                    activeDotColor: customColors.primary!, // 활성 인디케이터 색상
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

  TutorialPageView({required this.controller, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller, // 페이지 컨트롤러
      onPageChanged: onPageChanged, // 페이지가 변경될 때 호출되는 콜백
      children: [
        TutorialPage(
          title: 'tutorial.page1.title'.tr(),
          content: 'tutorial.page1.content'.tr(),
          image: 'assets/images/tutorial1.png',
        ),
        TutorialPage(
          title: 'tutorial.page2.title'.tr(),
          content: 'tutorial.page2.content'.tr(),
          image: 'assets/images/tutorial2.png',
        ),
        TutorialPage(
          title: 'tutorial.page3.title'.tr(),
          content: 'tutorial.page3.content'.tr(),
          image: 'assets/images/tutorial3.png',
        ),
        TutorialPage(
          title: 'tutorial.page4.title'.tr(),
          content: 'tutorial.page4.content'.tr(),
          image: 'assets/images/tutorial4.png',
          showStartButton: true,
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

  TutorialPage({
    required this.title,
    required this.content,
    required this.image,
    this.showStartButton = false,
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
                function: () {
                  print("시작하기 버튼이 눌렸습니다!");
                  Navigator.pushReplacementNamed(context, '/'); // 버튼 클릭 시 메인 화면으로 이동
                },
                title: '시작하기'.tr(),
              ),
            ),
          ),
      ],
    );
  }
}
