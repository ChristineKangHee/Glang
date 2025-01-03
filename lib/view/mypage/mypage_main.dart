/// File: mypage_main.dart
/// Purpose: 마이페이지 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/font.dart';

class MyPageMain extends ConsumerStatefulWidget {
  const MyPageMain({super.key});

  @override
  ConsumerState<MyPageMain> createState() => _MyPageMainState();
}

class _MyPageMainState extends ConsumerState<MyPageMain> with SingleTickerProviderStateMixin{
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
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pretendard 폰트 테스트'),
              Text(
                'Pretendard Variable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard Thin (Weight 100)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard ExtraLight (Weight 200)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard Light (Weight 300)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard Regular (Weight 400)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard Medium (Weight 500)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard SemiBold (Weight 600)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard Bold (Weight 700)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Pretendard ExtraBold (Weight 800)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
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
