import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../models/allowance_model.dart';
import '../utils/decimal_formatter.dart';

class MainScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final GlobalKey _resultsKey = GlobalKey(); // For capturing results as JPEG
  final TextEditingController transportationController =
      TextEditingController();
  final TextEditingController socialInsuranceController =
      TextEditingController();
  final TextEditingController raisePercentageController =
      TextEditingController();

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salary Calculator')),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Base Salary Input
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction
                    .done, // Adds a 'Done' button to the keyboard
                decoration: InputDecoration(labelText: 'Base Salary'),
                onChanged: (value) {
                  controller.updateBaseSalary(double.tryParse(value) ?? 0.0);
                },
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus(); // Dismiss the keyboard
                },
              ),
              SizedBox(height: 10),

              // Toggle for Raise
              Obx(() => Row(
                    children: [
                      Text("Received Raise?"),
                      Spacer(),
                      Switch(
                        value: controller.hasRaise.value,
                        onChanged: (value) {
                          controller.toggleRaise(value);
                        },
                      ),
                    ],
                  )),
              SizedBox(height: 10),

              // Raise Percentage Input (Visible if Toggle is On)
              Obx(() {
                if (controller.hasRaise.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction
                            .done, // Adds a 'Done' button to the keyboard
                        inputFormatters: [
                          DecimalInputFormatter(decimalPlaces: 2)
                        ],
                        decoration:
                            InputDecoration(labelText: 'Raise Percentage (%)'),
                        onChanged: (value) {
                          controller.updateRaisePercentage(
                              double.tryParse(value) ?? 0.0);
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context)
                              .unfocus(); // Dismiss the keyboard
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Raise Amount: SAR ${controller.raiseAmount.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "New Base Salary: SAR ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
              SizedBox(height: 10),

              // Housing Allowance Input
              Obx(() {
                final TextEditingController housingController =
                    TextEditingController(
                        text: controller.housingAllowancePercentage.value
                            .toStringAsFixed(2)
                            .replaceAll(RegExp(r'\.00$'), ''));
                housingController.selection = TextSelection.collapsed(
                    offset: housingController.text.length);

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: housingController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          DecimalInputFormatter(
                              decimalPlaces: 2) // Ensures correct format
                        ],
                        decoration:
                            InputDecoration(labelText: 'Housing Allowance (%)'),
                        onChanged: (value) {
                          String cleanValue = value
                              .replaceAll('%', '')
                              .trim(); // Remove % for parsing

                          if (cleanValue.isEmpty) {
                            controller.updateHousingAllowance(0.0);
                          } else {
                            final parsedValue = double.tryParse(cleanValue);
                            if (parsedValue != null) {
                              controller.updateHousingAllowance(parsedValue);
                            }
                          }
                        },
                        onEditingComplete: () {
                          // Add % symbol when the user finishes editing
                          final valueWithSymbol =
                              "${controller.housingAllowancePercentage.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}%";
                          housingController.value =
                              housingController.value.copyWith(
                            text: valueWithSymbol,
                            selection: TextSelection.collapsed(
                                offset: valueWithSymbol.length - 1),
                          );
                          FocusScope.of(context)
                              .unfocus(); // Close the keyboard
                        },
                        onTap: () {
                          // Remove % symbol temporarily when the user taps the field
                          String cleanValue =
                              housingController.text.replaceAll('%', '');
                          housingController.value =
                              housingController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(
                                offset: cleanValue.length),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "SAR ${controller.housingAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),
              SizedBox(height: 10),
              // Transportation Allowance Input
              Obx(() {
                final TextEditingController transportationController =
                    TextEditingController(
                        text: controller.transportationAllowancePercentage.value
                            .toStringAsFixed(2)
                            .replaceAll(RegExp(r'\.00$'), ''));
                transportationController.selection = TextSelection.collapsed(
                    offset: transportationController.text.length);

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: transportationController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          DecimalInputFormatter(decimalPlaces: 2)
                        ],
                        decoration: InputDecoration(
                            labelText: 'Transportation Allowance (%)'),
                        onChanged: (value) {
                          String cleanValue = value.replaceAll('%', '').trim();

                          if (cleanValue.isEmpty) {
                            controller.updateTransportationAllowance(0.0);
                          } else {
                            final parsedValue = double.tryParse(cleanValue);
                            if (parsedValue != null) {
                              controller
                                  .updateTransportationAllowance(parsedValue);
                            }
                          }
                        },
                        onEditingComplete: () {
                          final valueWithSymbol =
                              "${controller.transportationAllowancePercentage.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}%";
                          transportationController.value =
                              transportationController.value.copyWith(
                            text: valueWithSymbol,
                            selection: TextSelection.collapsed(
                                offset: valueWithSymbol.length - 1),
                          );
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          String cleanValue =
                              transportationController.text.replaceAll('%', '');
                          transportationController.value =
                              transportationController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(
                                offset: cleanValue.length),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "SAR ${controller.transportationAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),

              SizedBox(height: 10),
              // Social Insurance Input
              Obx(() {
                final TextEditingController socialInsuranceController =
                    TextEditingController(
                        text: controller.socialinsurancePercentage.value
                            .toStringAsFixed(2)
                            .replaceAll(RegExp(r'\.00$'), ''));
                socialInsuranceController.selection = TextSelection.collapsed(
                    offset: socialInsuranceController.text.length);

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: socialInsuranceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          DecimalInputFormatter(decimalPlaces: 2)
                        ],
                        decoration:
                            InputDecoration(labelText: 'Social Insurance (%)'),
                        onChanged: (value) {
                          String cleanValue = value.replaceAll('%', '').trim();

                          if (cleanValue.isEmpty) {
                            controller.updatesocialinsurancePercentage(0.0);
                          } else {
                            final parsedValue = double.tryParse(cleanValue);
                            if (parsedValue != null) {
                              controller
                                  .updatesocialinsurancePercentage(parsedValue);
                            }
                          }
                        },
                        onEditingComplete: () {
                          final valueWithSymbol =
                              "${controller.socialinsurancePercentage.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}%";
                          socialInsuranceController.value =
                              socialInsuranceController.value.copyWith(
                            text: valueWithSymbol,
                            selection: TextSelection.collapsed(
                                offset: valueWithSymbol.length - 1),
                          );
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          String cleanValue = socialInsuranceController.text
                              .replaceAll('%', '');
                          socialInsuranceController.value =
                              socialInsuranceController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(
                                offset: cleanValue.length),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "SAR ${controller.socialSecurityAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20),

              // Allowances List
              Obx(() => Column(
                    children: controller.allowances
                        .asMap()
                        .entries
                        .map((entry) {
                          int index = entry.key;
                          var allowance = entry.value;
                          return ListTile(
                            title: Text(
                                '${allowance.name}: ${allowance.type == AllowanceType.fixed ? "SAR ${allowance.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}" : "${allowance.percentageInput?.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}% → SAR ${allowance.value}"}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      controller.editAllowance(context, index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    controller.allowances.removeAt(index);
                                  },
                                ),
                              ],
                            ),
                          );
                        })
                        .toList()
                        .cast<Widget>(),
                  )),

              SizedBox(height: 20),

              // Results Container

              // Results Container
              Obx(() => RepaintBoundary(
                    key: _resultsKey,
                    child: Container(
                      width: double.infinity, // Makes the box take full width
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Conditional New Base Salary Display
                          _buildResultRow(
                            controller.hasRaise.value
                                ? 'New Base Salary'
                                : 'Base Salary',
                            'SAR ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            // isBold: true,
                          ),
                          _buildResultRow(
                            'Housing Allowance',
                            'SAR ${controller.housingAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                          ),
                          _buildResultRow(
                            'Transportation Allowance',
                            'SAR ${controller.transportationAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                          ),
                          _buildResultRow(
                            'Social Insurance Deduction',
                            'SAR ${controller.socialSecurityAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                          ),
                          ...controller.allowances
                              .map((allowance) => _buildResultRow(
                                    allowance.name,
                                    'SAR ${allowance.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                                  )),
                          _buildResultRow(
                            'Pre-Deduction Total',
                            'SAR ${controller.preDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                          ),
                          _buildResultRow(
                            'Post-Deduction Total',
                            'SAR ${controller.postDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                          ),
                        ],
                      ),
                    ),
                  )),

              // Obx(() => RepaintBoundary(
              //       key: _resultsKey,
              //       child: Container(
              //         padding: const EdgeInsets.all(16.0),
              //         decoration: BoxDecoration(
              //           color: Colors.grey[200],
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             // Conditional New Base Salary Display
              //             if (controller.hasRaise.value)
              //               Text(
              //                 'New Base Salary: SAR ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
              //                 style: TextStyle(fontWeight: FontWeight.bold),
              //               )
              //             else
              //               Text(
              //                 'Base Salary: SAR ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
              //                 style: TextStyle(fontWeight: FontWeight.bold),
              //               ),
              //             Text(
              //                 'Housing Allowance: SAR ${controller.housingAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}'),
              //             Text(
              //                 'Transportation Allowance: SAR ${controller.transportationAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}'),
              //             Text(
              //                 'Social Insurance Deduction: SAR ${controller.socialSecurityAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}'),
              //             ...controller.allowances.map((allowance) => Text(
              //                 '${allowance.name}: SAR ${allowance.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}}')),
              //             Text(
              //                 'Pre-Deduction Total: SAR ${controller.preDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}'),
              //             Text(
              //                 'Post-Deduction Total: SAR ${controller.postDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}'),
              //           ],
              //         ),
              //       ),
              //     )),

              SizedBox(height: 20),

              // Save Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.saveResultsAsPDF(),
                    child: Text('Save as PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.saveResultsAsJPEG(_resultsKey),
                    child: Text('Save as JPEG'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addAllowance(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.0,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
