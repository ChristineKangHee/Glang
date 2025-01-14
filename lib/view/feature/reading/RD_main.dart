import 'package:flutter/material.dart';

import '../../components/custom_app_bar.dart';

class RdMain extends StatelessWidget {
  const RdMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_7(title: "읽기 중"),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            // ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => ChangeEndingMain(),
            // )), child: Text("결말바꾸기")),
          ],
        ),
      )),
    );
  }
}
