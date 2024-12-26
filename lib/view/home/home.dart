import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('app_title')), // 앱 제목 번역
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('welcome_message'), // 환영 메시지 번역
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 예: 다른 페이지로 이동
              },
              child: Text(tr('login')), // 로그인 버튼 번역
            ),
            ElevatedButton(
              onPressed: () {
                context.setLocale(Locale('ko')); // 한국어로 전환
              },
              child: const Text('Switch to Korean'),
            ),
            ElevatedButton(
              onPressed: () {
                context.setLocale(Locale('en')); // 영어로 전환
              },
              child: const Text('Switch to English'),
            ),

          ],
        ),
      ),
    );
  }
}
