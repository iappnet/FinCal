import 'package:get/get.dart';
import '../bindings/salary_calculation_binding.dart'; // Create this if needed
import '../views/calculation_details_screen.dart';
import '../views/history_screen.dart';
import '../views/home_screen.dart';
import '../views/investment_calculation_screen.dart';
import '../views/loan_calculation_screen.dart';
import '../views/salary_calculation_screen.dart';
import '../views/settings_screen.dart'; // Import the MainScreen

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home; // Updated to HomeScreen

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: _Paths.salaryCalculation,
      page: () => SalaryCalculationScreen(),
      binding: SalaryCalculationBinding(),
    ),
    GetPage(
      name: Routes.history,
      page: () => HistoryScreen(),
    ),
    GetPage(
      name: Routes.calculationDetails,
      page: () => CalculationDetailsScreen(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => SettingsScreen(),
    ),
    GetPage(
      name: _Paths.investmentCalculation,
      page: () =>
          InvestmentCalculation(title: 'Investment Calculation Coming Soon'),
    ),
    GetPage(
      name: _Paths.loanCalculation,
      page: () => LoanCalculation(title: 'Loan Calculation Coming Soon'),
    ),
  ];
}
