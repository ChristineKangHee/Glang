import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';

import '../../theme/font.dart';

class MyPageMain extends StatefulWidget {
  const MyPageMain({super.key});

  @override
  State<MyPageMain> createState() => _MyPageMainState();
}

class _MyPageMainState extends State<MyPageMain> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar_MyPage(),
          body: PretendardFontTestPage(),
          bottomNavigationBar: CustomNavigationBar(),
        )
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
