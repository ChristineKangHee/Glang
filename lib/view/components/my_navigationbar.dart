import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodel/navigation_controller.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(() {
      return BottomNavigationBar(
        currentIndex: navController.selectedIndex.value,
        onTap: (index) => navController.navigateToIndex(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Reading"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Page"),
        ],
      );
    });
  }
}
