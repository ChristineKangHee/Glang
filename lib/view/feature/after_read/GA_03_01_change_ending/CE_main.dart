import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';

class ChangeEndingMain extends StatelessWidget {
  const ChangeEndingMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_6(title: "결말 바꾸기"),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("글의 결말을 읽고\n"),
                Row(
                  children: [
                    Text("나만의 결말"),
                    Text("을 만들어볼까요?"),
                  ],
                ),
              ],
            ),
          )
      )
    );
  }
}
