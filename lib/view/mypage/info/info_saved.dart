/// File: saved.dart
/// Purpose: 저장한 문장과 단어,질문들을 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-08 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class MyPageSaved extends ConsumerWidget {
  const MyPageSaved({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar:
      AppBar(
        title: const Text('app_title').tr(),
      ),
      body: Column(
        children: [
          Text("저장"),
        ],
      ),
    );
  }
}