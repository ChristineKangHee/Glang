import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EulaScreen extends StatelessWidget {
  const EulaScreen({Key? key}) : super(key: key);

  Future<void> _acceptEula(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eulaAccepted', true);

    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('약관 동의')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '여기에 서비스 이용 약관 내용을 표시합니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _acceptEula(context),
              child: Text('약관에 동의합니다'),
            ),
          ],
        ),
      ),
    );
  }
}
