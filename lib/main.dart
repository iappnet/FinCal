// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'app/routes/app_pages.dart';

// void main() {
//   runApp(
//     GetMaterialApp(
//       title: "Salary Calculator",
//       initialRoute: AppPages.initial, // Start with the MAIN route
//       debugShowCheckedModeBanner: false,
//       getPages: AppPages.routes, // Use the defined routes
//       theme: ThemeData.light(), // Optional: Apply light theme globally
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/bottom_navigation_controller.dart';
import 'app/controllers/home_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/shared_bottom_navbar.dart';
import 'app/views/history_screen.dart';
import 'app/views/home_screen.dart';
import 'app/views/salary_calculation_screen.dart';
import 'app/views/settings_screen.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Financial Tools",
      initialRoute: AppPages.initial, // Ensure it starts at the correct route
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes, // Register all routes here
      home: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  final BottomNavigationController controller =
      Get.put(BottomNavigationController());
  final HomeController homeController = Get.put(HomeController());

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Determine the active screen
        switch (controller.currentIndex.value) {
          case 0:
            return HomeScreen();
          case 1:
            return SalaryCalculationScreen();
          case 2:
            return HistoryScreen();
          case 3:
            return SettingsScreen();
          case 4:
            return Center(child: Text("Investment Calculation Coming Soon"));
          default:
            return Center(child: Text("Feature Coming Soon"));
        }
      }),
      bottomNavigationBar: SharedBottomNavBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Salary Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Calculation History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications_outlined),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
