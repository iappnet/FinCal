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
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                spreadRadius: 3,
                blurRadius: 8,
                offset: Offset(0, 4)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0, // Optional for a clean look
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.changeTab(index),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[300],
          items: items,
        ),
      );
    });
  }
}
