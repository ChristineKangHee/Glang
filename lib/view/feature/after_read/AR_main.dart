import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/feature/after_read/GA_03_01_change_ending/CE_main.dart';
import 'package:readventure/view/feature/after_read/GA_03_04_diagram/diagram_main.dart';

import 'GA_03_05_writing_form/writing_form_main.dart';

class ArMain extends StatelessWidget {
  const ArMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_7(title: "읽기 후"),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChangeEndingMain(),
            )), child: Text("결말바꾸기")),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => RootedTreeScreen(),
            )), child: Text("다이어그램")),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => SentencePractice(),
            )), child: Text("문장형식연습")),
          ],
        ),
      )),
    );
  }
}
