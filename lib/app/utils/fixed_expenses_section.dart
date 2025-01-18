import 'package:fincals/app/controllers/personal_finance_controller.dart';
import 'package:fincals/app/utils/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FixedExpensesSection extends StatelessWidget {
  final PersonalFinanceController controller =
      Get.find<PersonalFinanceController>();

  FixedExpensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized before building the UI
    controller.refreshControllers();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Fixed Monthly Expenses",
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          // ),
          // SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.fixedExpenses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InputField(
                        label: 'expense_title'.tr,
                        controller: controller.titleControllers[index],
                        onChanged: (value) {
                          controller.updateExpense(
                            index,
                            value,
                            double.tryParse(
                                    controller.amountControllers[index].text) ??
                                0.0,
                          );
                          controller.saveFixedExpenses();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: InputField(
                        label: 'amount_label'.tr,
                        controller: controller.amountControllers[index],
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final updatedAmount = double.tryParse(value) ?? 0.0;
                          controller.updateExpense(
                              index,
                              controller.titleControllers[index].text,
                              updatedAmount);
                          controller.saveFixedExpenses();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        controller.removeExpense(index);
                        controller.saveFixedExpenses();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              controller.addExpense('new_expense'.tr, 0.0);
              controller.saveFixedExpenses();
            },
            child: Text('add_expense_button'.tr),
          ),
          SizedBox(height: 16),
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'total_fixed_expenses'.tr}: ${controller.totalFixedExpenses.toStringAsFixed(2)} ${'sar'.tr}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${'remaining_balance_label'.tr}: ${controller.remainingBalanceAfterFixed.toStringAsFixed(2)} ${'sar'.tr}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
        ],
      );
    });
  }
}
