import 'package:flutter/material.dart';

class MyTapBar extends StatelessWidget{
  final TabController tablController;
  const MyTapBar({
    super.key,
    required this.tablController
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
        controller: tablController,
        tabs: [
          Tab(text: '메뉴',),
          Tab(text: '정보',),
          Tab(text: '리뷰',),
        ],
      ),
    );
  }

}