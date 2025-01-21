import 'package:flutter/material.dart';

void _showStartDialog(BuildContext context, int roundNumber) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("라운드 시작"),
      content: Text("라운드 $roundNumber가 시작됩니다."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("확인"),
        ),
      ],
    ),
  );
}

void _showPauseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("일시 정지"),
      content: Text("타이머가 일시 정지되었습니다."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("재개"),
        ),
      ],
    ),
  );
}
