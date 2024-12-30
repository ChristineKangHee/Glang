import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';

class MyPageMain extends StatelessWidget {
  const MyPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(title: 'app_title'),
          body: Placeholder(),
          bottomNavigationBar: CustomNavigationBar(),
        )
    );
  }
}
