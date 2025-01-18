import 'package:fincals/app/utils/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fincals/app/controllers/personal_finance_controller.dart';

class RecurringExpensesSection extends StatelessWidget {
  final PersonalFinanceController controller =
      Get.find<PersonalFinanceController>();

  RecurringExpensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          // Remove any shadows or borders
          color: Colors.transparent,
          boxShadow: [], // Explicitly clear shadows
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero, // Remove default padding
              itemCount: controller.recurringExpenses.length,
              itemBuilder: (context, index) {
                return Container(
                  // Wrap with a transparent container for clean styling
                  margin: EdgeInsets.symmetric(vertical: 4.0), // Adjust spacing
                  child: Row(
                    children: [
                      Expanded(
                        child: InputField(
                          label: 'expense_title'.tr,
                          controller:
                              controller.recurringTitleControllers[index],
                          onChanged: (value) {
                            controller.updateRecurringExpense(
                              index,
                              value,
                              double.tryParse(controller
                                      .recurringAmountControllers[index]
                                      .text) ??
                                  0.0,
                              int.tryParse(controller
                                      .recurringFrequencyControllers[index]
                                      .text) ??
                                  1,
                            );
                            controller.saveRecurringExpenses();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: InputField(
                          label: 'amount_label'.tr,
                          controller:
                              controller.recurringAmountControllers[index],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final updatedAmount = double.tryParse(value) ?? 0.0;
                            controller.updateRecurringExpense(
                              index,
                              controller.recurringTitleControllers[index].text,
                              updatedAmount,
                              int.tryParse(controller
                                      .recurringFrequencyControllers[index]
                                      .text) ??
                                  1,
                            );
                            controller.saveRecurringExpenses();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: InputField(
                          label: 'frequency_label'.tr,
                          controller:
                              controller.recurringFrequencyControllers[index],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final updatedFrequency = int.tryParse(value) ?? 1;
                            controller.updateRecurringExpense(
                              index,
                              controller.recurringTitleControllers[index].text,
                              double.tryParse(controller
                                      .recurringAmountControllers[index]
                                      .text) ??
                                  0.0,
                              updatedFrequency,
                            );
                            controller.saveRecurringExpenses();
                          },
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.fromLTRB(0, 23, 0, 0),
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          controller.removeRecurringExpense(index);
                          controller.saveRecurringExpenses();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                controller.addRecurringExpense('new_expense'.tr, 0.0, 1);
                controller.saveRecurringExpenses();
              },
              child: Text('add_periodic_expense_button'.tr),
            ),
            SizedBox(height: 16),
            Text(
              "${'total_annual_periodic_expenses'.tr} ${controller.totalAnnualRecurringExpenses.toStringAsFixed(2)} SAR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${'total_monthly_periodic_expenses'.tr} ${controller.totalMonthlyRecurringExpenses.toStringAsFixed(2)} SAR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${'remaining_balance_label'.tr} ${controller.remainingBalanceAfterRecurring.toStringAsFixed(2)} SAR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }
}
