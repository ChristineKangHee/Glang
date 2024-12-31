/// File: navigation_controller.dart
/// Purpose: 앱의 네비게이션 상태를 관리하고 페이지 전환을 제어
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view/community/community_main.dart';
import '../view/course/course_main.dart';
import '../view/home/home.dart';
import '../view/mypage/mypage_main.dart';

final navigationProvider = StateNotifierProvider<NavigationController, int>((ref) {
  return NavigationController();
});

class NavigationController extends StateNotifier<int> {
  NavigationController() : super(0); // 초기값: 0 (홈 화면)

  void setSelectedIndex(int index) {
    state = index; // 상태 업데이트
  }

  void navigateToIndex(BuildContext context, int index) {
    setSelectedIndex(index);
    switch (index) {
      case 0:
        _navigateWithoutAnimation(context, '/'); // Home
        break;
      case 1:
        _navigateWithoutAnimation(context, '/course'); // Course
        break;
      case 2:
        _navigateWithoutAnimation(context, '/community'); // Community
        break;
      case 3:
        _navigateWithoutAnimation(context, '/mypage'); // MyPage
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
