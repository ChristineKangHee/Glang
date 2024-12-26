import 'package:flutter/material.dart';
import 'package:readventure/localization/app_localizations.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Localization 사용

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.translate('app_title')), // 앱 제목
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.translate('welcome_message'), // 환영 메시지
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 예: 다른 페이지로 이동
              },
              child: Text(localizations.translate('login')), // 로그인 버튼
            ),
          ],
        ),
      ),
    );
  }
}
