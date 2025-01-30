/// File: custom_tab_bar.dart
/// Purpose: 커스터마이즈된 TabBar 위젯을 제공하여 다양한 탭 항목(전체, 안읽음, 학습, 보상, 시스템)을 표시
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';

class CustomTapBar extends StatelessWidget{
  final TabController tablController;
  const CustomTapBar({
    super.key,
    required this.tablController
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
        controller: tablController,
        tabs: [
          Tab(text: '전체',),
          Tab(text: '안읽음',),
          Tab(text: '코스',),
          Tab(text: '보상',),
          Tab(text: '시스템',),
        ],
      ),
    );
  }

}