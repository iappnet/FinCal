import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/calculation_model.dart';

class CalculationDetailsScreen extends StatelessWidget {
  const CalculationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculation = Get.arguments as CalculationModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('${calculation.calculationType} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calculation Date: ${calculation.date.toLocal()}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...calculation.details.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }),
          ],
        ),
      ),
    );
  }
}
