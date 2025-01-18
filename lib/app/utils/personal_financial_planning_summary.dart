import 'package:fincals/app/controllers/personal_finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalFinancialPlanningSummary extends StatelessWidget {
  final PersonalFinanceController controller =
      Get.find<PersonalFinanceController>();

  PersonalFinancialPlanningSummary({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine device width
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // iPads/Macs have wider screens
    final boxWidth =
        isWideScreen ? 600.0 : screenWidth - 32; // Max width for larger screens

    return Obx(() {
      return Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.greenAccent[100],
          child: Container(
            width: boxWidth, // Adjust width based on the screen size
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'summary_title'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                _buildSummaryRow(
                  'total_income_amount'.tr,
                  (controller.monthlyIncome.value +
                          controller.additionalIncome.value)
                      .toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'fixed_expenses_section_title'.tr,
                  controller.totalFixedExpenses.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'total_monthly_periodic_expenses'.tr,
                  controller.totalMonthlyRecurringExpenses.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'total_annual_periodic_expenses'.tr,
                  controller.totalAnnualRecurringExpenses.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'savings_and_emergency_label'.tr,
                  controller.emergencySavings.value.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'investment_amount'.tr,
                  controller.investments.value.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'remaining_balance_label'.tr,
                  controller.remainingBalanceAfterSavings.toStringAsFixed(2),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
