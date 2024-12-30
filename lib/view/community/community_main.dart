import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';

class CommunityMain extends StatelessWidget {
  const CommunityMain({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: const CustomAppBar(title: 'app_title'),
          body: Placeholder(),
          bottomNavigationBar: const CustomNavigationBar(),
        )
    );
  }
}
