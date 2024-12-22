import 'package:get/get.dart';
import '../models/summary_model.dart'; // Define a model for the summary card

class HomeController extends GetxController {
  // final someObservable = 0.obs; // Example initialization

// Reactive variables to track summaries
  var currentSummary = SummaryModel(
    calculationType: 'salary'.tr,
    details: 'recent_salary_calc'.trParams({'amount': 'SAR 20,000'}),
  ).obs;

  var salarySummary = SummaryModel(
    calculationType: 'salary'.tr,
    details: 'no_salary_calc'.tr,
  ).obs;

  var investmentSummary = SummaryModel(
    calculationType: 'investment'.tr,
    details: 'no_investment_calc'.tr,
  ).obs;

  var loanSummary = SummaryModel(
    calculationType: 'loan'.tr,
    details: 'no_loan_calc'.tr,
  ).obs;

// Method to update summaries dynamically
  void updateSummary(String type, String details) {
    switch (type) {
      case 'Salary':
        salarySummary.value = SummaryModel(
          calculationType: 'salary'.tr,
          details: details,
        );
        break;
      case 'Investment':
        investmentSummary.value = SummaryModel(
          calculationType: 'investment'.tr,
          details: details,
        );
        break;
      case 'Loan':
        loanSummary.value = SummaryModel(
          calculationType: 'loan'.tr,
          details: details,
        );
        break;
    }
    currentSummary.value = SummaryModel(
      calculationType: type.tr,
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
