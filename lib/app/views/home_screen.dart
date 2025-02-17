import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/settings_controller.dart';
import '../routes/app_pages.dart';
import '../utils/shared_appbar.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final SettingsController settingsController =
      Get.find<SettingsController>(); // Use the existing SettingsController

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'app_title'.tr,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      // AppBar(
      //   title: Text('Financial Tools'),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Obx(() {
              final greeting = settingsController.isFirstUse.value
                  ? 'welcome'.tr
                  : 'welcome_back'.trParams({
                      'username': settingsController.username.value,
                    });
              return Text(
                greeting,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            }),
            SizedBox(height: 8),
            Text(
              "${'today_is'.tr} ${DateTime.now().toLocal().toString().split(' ')[0]}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Grid Navigation Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavigationCard(
                    context,
                    title: 'salary_calculation'.tr,
                    description: 'calculate_salary_description'.tr,
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      Get.toNamed(Routes.salaryCalculation);
                    },
                  ),
                  _buildNavigationCard(
                    context,
                    title: 'personal_finance_view_title'.tr,
                    description: 'plan_your_financial_obligations'.tr,
                    icon: Icons.monetization_on,
                    onTap: () {
                      Get.toNamed(Routes.personalFinanceView);
                    },
                  ),
                  // _buildNavigationCard(
                  //   context,
                  //   title: 'Loan Calculation',
                  //   description: 'Manage your loans.',
                  //   icon: Icons.attach_money,
                  //   onTap: () {
                  //     Get.toNamed(Routes.loanCalculation);
                  //   },
                  // ),
                  _buildNavigationCard(
                    context,
                    title: 'more_features'.tr,
                    description: 'coming_soon'.tr,
                    icon: Icons.more_horiz,
                    onTap: () {
                      Get.snackbar('info'.tr, 'more_features_coming_soon'.tr);
                    },
                  ),
                ],
              ),
            ),

            // Dynamic Summary Card
            // _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              // padding: const EdgeInsets.all(16.0),
              padding: EdgeInsets.all(
                  constraints.maxWidth * 0.08), // Dynamic padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon,
                      // size: 40,
                      size: constraints.maxWidth * 0.2, // Dynamic icon size
                      color: Theme.of(context).primaryColor),
                  // SizedBox(height: 16),
                  SizedBox(
                      height: constraints.maxHeight * 0.05), // Dynamic spacing
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // fontSize: 16,
                        fontSize:
                            constraints.maxWidth * 0.08, // Dynamic font size
                        fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 8),
                  SizedBox(
                      height: constraints.maxHeight * 0.05), // Dynamic spacing
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // fontSize: 14,
                        fontSize:
                            constraints.maxWidth * 0.07, // Dynamic font size
                        color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildSummaryCard() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'most_recent_summary'.tr,
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 8),
  //           Obx(() {
  //             // Retrieve dynamic content from the controller
  //             final summary = controller.currentSummary.value;
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text('${'calculation_type'.tr}: ${summary.calculationType}'),
  //               ],
  //             );
  //           }),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
