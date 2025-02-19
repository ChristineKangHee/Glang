import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  /// 앱 전체를 재시작하기 위해 호출합니다.
  static void restartApp(BuildContext context) {
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey(); // 새로운 키를 부여하여 전체 위젯 트리 재생성
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
