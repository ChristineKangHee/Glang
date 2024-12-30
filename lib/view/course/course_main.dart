import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';

class CourseMain extends StatelessWidget {
  const CourseMain({super.key});

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
