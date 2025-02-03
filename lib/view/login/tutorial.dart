import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/theme.dart';
import '../components/custom_button.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TutorialPageView(controller: _controller),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 4, // 페이지 수는 5로 변경
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
    );
  }
}

class TutorialPageView extends StatelessWidget {
  final PageController controller;

  TutorialPageView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
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
  final bool showStartButton; // 시작하기 버튼을 보여줄지 여부

  TutorialPage({
    required this.title,
    required this.content,
    required this.image,
    this.showStartButton = false, // 기본값은 false
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    // 디바이스 화면 크기 정보 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * 0.8; // 화면 너비의 90%로 이미지 크기 조정

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end, // 아래쪽 정렬
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
        SizedBox(height: 16,),
        ClipRRect(
          child: Image.asset(
            image,
            width: screenWidth, // 화면 너비에 맞춤
            height: screenWidth * 1.2, // 적절한 높이 설정 (화면 비율에 따라 조정)
            fit: BoxFit.cover, // 위쪽을 기준으로 아래쪽이 잘리도록 설정
            alignment: Alignment.topCenter, // 위쪽 정렬
          ),
        ),
        // 마지막 페이지에서만 "시작하기" 버튼 추가
        if (showStartButton)
          Container(
            width: MediaQuery.of(context).size.width,
            child: ButtonPrimary(
              function: () {
                print("시작하기 버튼이 눌렸습니다!");
                // 시작하기 버튼을 눌렀을 때의 동작을 여기에 정의
                Navigator.pushNamed(context, '/'); // '/'로 이동
              },
              title: '시작하기',
            ),
          ),
      ],
    );
  }
}
