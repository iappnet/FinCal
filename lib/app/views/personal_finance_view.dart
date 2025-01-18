import 'package:fincals/app/utils/collapsible_section.dart';
import 'package:fincals/app/utils/fixed_expenses_section.dart';
import 'package:fincals/app/utils/Income_section.dart';
import 'package:fincals/app/utils/personal_financial_planning_summary.dart';
import 'package:fincals/app/utils/periodic_expenses_section.dart';
import 'package:fincals/app/utils/savings_emergency_funds_section.dart';
import 'package:fincals/app/utils/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/personal_finance_controller.dart';

class PersonalFinanceView extends StatelessWidget {
  final PersonalFinanceController controller =
      Get.put(PersonalFinanceController());

  PersonalFinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'personal_finance_view_title'.tr,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CollapsibleSection(
              title: 'income_section_title'.tr,
              child: IncomeSection(),
            ),
            SizedBox(height: 16),
            CollapsibleSection(
              title: 'fixed_expenses_section_title'.tr,
              child: FixedExpensesSection(),
            ),
            SizedBox(height: 16),
            CollapsibleSection(
              title: 'periodic_expenses_section_title'.tr,
              child: RecurringExpensesSection(),
            ),
            SizedBox(height: 16),
            CollapsibleSection(
              title: 'savings_section_title'.tr,
              child: SavingsSection(),
            ),
            SizedBox(height: 16),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: controller.showSummary ? 1.0 : 0.0,
              child: PersonalFinancialPlanningSummary(),
            ),
            // PersonalFinancialPlanningSummary(),
            SizedBox(height: 16),
            // Footer Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.withOpacity(0.2), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '“Planning is bringing the future into the present so that you can do something about it now.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 18),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Add export or analysis functionality
                  //   },
                  //   child: Text('Export Summary'),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
