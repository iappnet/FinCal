import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController controller = Get.put(HistoryController());

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculation History'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.calculations.isEmpty) {
          return Center(child: Text('No calculations saved.'));
        }
        return ListView.builder(
          itemCount: controller.calculations.length,
          itemBuilder: (context, index) {
            final calculation = controller.calculations[index];
            return Card(
              child: ListTile(
                title: Text(calculation.calculationType),
                subtitle: Text(
                    'Date: ${calculation.date.toLocal().toString().split(' ')[0]}'),
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
        title: Text("Delete Calculation"),
        content: Text("Are you sure you want to delete this calculation?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete"),
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
