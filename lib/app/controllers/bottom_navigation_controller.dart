import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  // Current active tab index
  var currentIndex = 0.obs;

  // Method to update the index
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
