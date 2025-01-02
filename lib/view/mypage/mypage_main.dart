import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';

import '../../theme/font.dart';

class MyPageMain extends StatelessWidget {
  const MyPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(title: 'app_title'),
          body: PretendardFontTestPage(),
          bottomNavigationBar: CustomNavigationBar(),
        )
    );
  }
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('폰트 테스트 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '헤드라인 1',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '헤드라인 1',
                style: pretendardBold(context).copyWith(fontSize: 32), // 폰트 크기만 20으로 변경
              ),
              const SizedBox(height: 8),
              const Text(
                '헤드라인 2',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '헤드라인 2',
                style: pretendardBold(context).copyWith(fontSize: 24), // 폰트 크기만 20으로 변경
              ),
              const SizedBox(height: 8),
              const Text(
                '본문 텍스트 1: 기본 크기와 스타일',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '본문 텍스트 2: 기울임꼴 적용',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              const Text(
                '커스텀 텍스트 스타일: 굵고 기울임',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(),
              const Text(
                '한글 폰트 테스트: 안녕하세요, 플러터!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                '영문 폰트 테스트: Hello, Flutter!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                '숫자 및 기호 테스트: 12345! @#\$%^&*()',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PretendardFontTestPage extends StatelessWidget {
  const PretendardFontTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pretendard 폰트 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pretendard Variable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Thin (Weight 100)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard ExtraLight (Weight 200)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Light (Weight 300)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Regular (Weight 400)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Medium (Weight 500)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard SemiBold (Weight 600)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Bold (Weight 700)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard ExtraBold (Weight 800)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pretendard Black (Weight 900)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
