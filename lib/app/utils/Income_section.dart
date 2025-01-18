import 'package:fincals/app/controllers/personal_finance_controller.dart';
import 'package:fincals/app/utils/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomeSection extends StatelessWidget {
  final PersonalFinanceController controller =
      Get.put(PersonalFinanceController());

  final TextEditingController monthlyIncomeController = TextEditingController();
  final TextEditingController additionalIncomeController =
      TextEditingController();

  IncomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize TextEditingController with current values from the controller
    monthlyIncomeController.text =
        controller.monthlyIncome.value.toStringAsFixed(2);
    additionalIncomeController.text =
        controller.additionalIncome.value.toStringAsFixed(2);

    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Income",
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          // // ),
          // SizedBox(height: 16),
          // Monthly Income Field
          InputField(
            label: 'monthly_income_label'.tr,
            controller: monthlyIncomeController,
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty
                ? 'invalid_amount_error'.tr
                : null,
            onChanged: (value) {
              controller.updateMonthlyIncome(value);
              controller.saveIncome();
            },
          ),
          SizedBox(height: 16),
          // Additional Income Field
          InputField(
            label: 'additional_income_label'.tr,
            controller: additionalIncomeController,
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty
                ? 'invalid_amount_error'.tr
                : null,
            onChanged: (value) {
              controller.updateAdditionalIncome(value);
              controller.saveIncome();
            },
          ),
          SizedBox(height: 16),
          // Total Income Display
          Obx(() {
            return Text(
              "${'total_income_amount'.tr} ${controller.totalIncome.toStringAsFixed(2)} ${'sar'.tr}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            );
          }),
        ],
      ),
    );
  }
}
