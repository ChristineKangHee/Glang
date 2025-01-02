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
          Tab(text: '학습',),
          Tab(text: '보상',),
          Tab(text: '시스템',),
        ],
      ),
    );
  }

}