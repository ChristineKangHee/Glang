import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class KeywordPicker extends StatefulWidget {
  @override
  _KeywordPickerState createState() => _KeywordPickerState();
}

class _KeywordPickerState extends State<KeywordPicker> {
  final List<String> keywords = [
    'AI', 'Flutter', 'JavaScript', 'Python', 'React', 'Dart', 'Machine Learning', 'Blockchain', 'Cloud', 'Database'
  ];

  double offset = 0;
  bool isSpinning = false;
  String selectedKeyword = '';
  late Timer timer;

  void startSpinning() {
    setState(() {
      isSpinning = true;
    });

    // 1초 동안 애니메이션을 빠르게 돌림
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        offset += 50;
        if (offset > keywords.length * 50) {
          offset = 0;
        }
      });
    });

    // 1초 후에 멈추고, 랜덤 키워드 선택
    Timer(Duration(seconds: 1), () {
      timer.cancel();
      setState(() {
        isSpinning = false;
        selectedKeyword = keywords[Random().nextInt(keywords.length)];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('랜덤 키워드 뽑기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedKeyword.isNotEmpty)
              Text(
                '선택된 키워드: $selectedKeyword',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            Stack(
              children: [
                AnimatedList(
                  initialItemCount: keywords.length,
                  itemBuilder: (context, index, animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.blueAccent,
                        child: Text(
                          keywords[index],
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSpinning ? null : startSpinning,
              child: Text(isSpinning ? '돌고 있습니다...' : '돌리기'),
            ),
          ],
        ),
      ),
    );
  }
}
