import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import '../utils/shared_appbar.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController controller = Get.put(HistoryController());

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure data refreshes when navigating to this screen
    controller.fetchCalculations();

    return Scaffold(
      appBar: SharedAppBar(
        title: 'calculation_history'.tr,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.calculations.isEmpty) {
          return Center(child: Text('no_calculations_saved'.tr)); // Localized
        }
        return ListView.builder(
          itemCount: controller.calculations.length,
          itemBuilder: (context, index) {
            final calculation = controller.calculations[index];
            return Card(
              child: ListTile(
                title: Text(
                  calculation.calculationType,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Date: ${calculation.date.toLocal().toString().split(' ')[0]}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, calculation.id!),
                ),
                onTap: () => controller.viewCalculationDetails(calculation),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("delete_calculation".tr), // Localized
        content: Text("delete_confirmation".tr), // Localized
        actions: [
          TextButton(
            child: Text("cancel".tr), // Localized
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("delete".tr), // Localized
            onPressed: () {
              controller.deleteCalculation(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
