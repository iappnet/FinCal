import 'package:fincals/app/controllers/personal_finance_controller.dart';
import 'package:fincals/app/utils/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SavingsSection extends StatefulWidget {
  const SavingsSection({super.key});

  @override
  SavingsSectionState createState() => SavingsSectionState();
}

class SavingsSectionState extends State<SavingsSection> {
  final PersonalFinanceController controller =
      Get.find<PersonalFinanceController>();

  // Persistent controllers
  late TextEditingController emergencyController;
  late TextEditingController investmentsController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with saved values from the controller
    emergencyController = TextEditingController(
      text: controller.emergencySavings.value.toString(),
    );
    investmentsController = TextEditingController(
      text: controller.investments.value.toString(),
    );

    // Add listeners to save changes
    emergencyController.addListener(() {
      controller.updateEmergencySavings(emergencyController.text);
      controller.saveSavings(); // Save to database
    });

    investmentsController.addListener(() {
      controller.updateInvestments(investmentsController.text);
      controller.saveSavings(); // Save to database
    });
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    emergencyController.dispose();
    investmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Savings and Emergency Funds",
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          // ),
          // SizedBox(height: 16),
          // Emergency Savings Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'emergency_savings_label'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: InputField(
                  label: 'monthly_amount_label'.tr,
                  controller: emergencyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value == null || value.isEmpty
                      ? 'invalid_amount_error'.tr
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Investments Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'investment_label'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: InputField(
                  label: 'monthly_amount_label'.tr,
                  controller: investmentsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value == null || value.isEmpty
                      ? 'invalid_amount_error'.tr
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Summary
          Text(
            "${'remaining_balance_label'.tr} ${controller.remainingBalanceAfterSavings.toStringAsFixed(2)} ${'sar'.tr}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    });
  }
}
