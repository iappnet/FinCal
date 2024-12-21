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
import 'app/controllers/settings_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/localization_service.dart';
import 'app/utils/shared_bottom_navbar.dart';
import 'app/views/history_screen.dart';
import 'app/views/home_screen.dart';
import 'app/views/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Localization JSON files before app launch
  await LocalizationService.loadJSON();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: "Financial Tools".tr, // Use translated title
        translations: LocalizationService(),
        locale: LocalizationService.locale,
        fallbackLocale: LocalizationService.fallbackLocale,
        supportedLocales: LocalizationService.locales,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return supportedLocales.first;
        },
        builder: (context, child) {
          final locale = Localizations.localeOf(context);
          final isRTL = locale.languageCode == 'ar';
          return Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          );
        },
        initialRoute: AppPages.initial,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.routes,
        theme: settingsController.isDarkMode.value
            ? ThemeData.dark()
            : ThemeData.light(),
      ),
    );
  }
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
          // case 1:
          //   return SalaryCalculationScreen();
          case 1:
            return HistoryScreen();
          case 2:
            return SettingsScreen();
          case 3:
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.calculate),
          //   label: 'Salary Calculator',
          // ),
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
