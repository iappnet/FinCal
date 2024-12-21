import 'package:get/get.dart';
import '../models/summary_model.dart'; // Define a model for the summary card

class HomeController extends GetxController {
  // final someObservable = 0.obs; // Example initialization

  // Reactive variables to track summaries
  var currentSummary = SummaryModel(
    calculationType: 'Salary',
    details: 'Your most recent salary calculation is SAR 20,000.',
  ).obs;

  var salarySummary = SummaryModel(
    calculationType: 'Salary',
    details: 'No recent salary calculation.',
  ).obs;

  var investmentSummary = SummaryModel(
    calculationType: 'Investment',
    details: 'No recent investment calculation.',
  ).obs;

  var loanSummary = SummaryModel(
    calculationType: 'Loan',
    details: 'No recent loan calculation.',
  ).obs;

  // Method to update summaries dynamically
  void updateSummary(String type, String details) {
    switch (type) {
      case 'Salary':
        salarySummary.value = SummaryModel(
          calculationType: 'Salary',
          details: details,
        );
        break;
      case 'Investment':
        investmentSummary.value = SummaryModel(
          calculationType: 'Investment',
          details: details,
        );
        break;
      case 'Loan':
        loanSummary.value = SummaryModel(
          calculationType: 'Loan',
          details: details,
        );
        break;
    }
    currentSummary.value = SummaryModel(
      calculationType: type,
      details: details,
    );
  }

  // Navigation methods
  void goToSalaryCalculation() {
    Get.toNamed('/salary-calculation');
  }

  void goToInvestmentCalculation() {
    Get.toNamed('/investment-calculation');
  }

  void goToLoanCalculation() {
    Get.toNamed('/loan-calculation');
  }
}
