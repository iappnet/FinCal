import 'package:get/get.dart';
import '../bindings/main_binding.dart'; // Create this if needed
import '../views/main_screen.dart'; // Import the MainScreen

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN,
      page: () => MainScreen(),
      binding: MainBinding(), // This should match the controller binding
    ),
  ];
}
