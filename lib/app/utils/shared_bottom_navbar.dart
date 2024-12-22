import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_navigation_controller.dart';

class SharedBottomNavBar extends StatelessWidget {
  final BottomNavigationController controller =
      Get.find<BottomNavigationController>();

  final List<BottomNavigationBarItem> items;

  SharedBottomNavBar({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.changeTab(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: items,
      );
    });
  }
}
