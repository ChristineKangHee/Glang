import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/community/community_main.dart';
import '../view/course/course_main.dart';
import '../view/mypage/mypage_main.dart';
import '../view/home/home.dart';

class NavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void navigateToIndex(BuildContext context, int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        _navigateWithoutAnimation(context, '/');
        break;
      case 1:
        _navigateWithoutAnimation(context, '/friend');
        break;
      case 2:
        _navigateWithoutAnimation(context, '/reading');
        break;
      case 3:
        _navigateWithoutAnimation(context, '/mypage');
        break;
    }
  }

  void _navigateWithoutAnimation(BuildContext context, String routeName) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _getPageByRouteName(routeName),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
          (route) => false,
    );
  }

  Widget _getPageByRouteName(String routeName) {
    switch (routeName) {
      case '/':
        return const MyHomePage();
      case '/course':
        return CourseMain();
      case '/community':
        return const CommunityMain();
      case '/mypage':
        return const MyPageMain();
      default:
        return const MyHomePage();
    }
  }
}
