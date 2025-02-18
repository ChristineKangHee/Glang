import 'package:flutter/material.dart';

class DoubleBackToExitWrapper extends StatefulWidget {
  final Widget child;
  const DoubleBackToExitWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _DoubleBackToExitWrapperState createState() => _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastPressedAt; // 마지막으로 뒤로가기 버튼 누른 시각

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('뒤로가기 버튼을 한 번 더 누르면 종료됩니다.')),
      );
      return false; // 앱 종료 안 함
    }
    return true; // 2초 이내 두 번 누르면 앱 종료
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
