import 'package:flutter/material.dart';
import 'package:readventure/view/feature/before_read/GA_01_01_cover_research/CR_main.dart';
import '../../components/custom_app_bar.dart';

class BrMain extends StatelessWidget {
  const BrMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_7(title: "읽기 전"),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => CoverResearchMain(),
            )), child: Text("표지 탐구하기")),
          ],
        ),
      )),
    );
  }
}
