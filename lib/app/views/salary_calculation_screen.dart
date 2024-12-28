import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/salary_calculation_controller.dart';
import '../models/allowance_model.dart';
import '../utils/decimal_formatter.dart';
import '../utils/shared_appbar.dart';

class SalaryCalculationScreen extends StatelessWidget {
  final SalaryCalculationController controller =
      Get.put(SalaryCalculationController());
  final GlobalKey _resultsKey = GlobalKey(); // For capturing results as JPEG
  final TextEditingController transportationController =
      TextEditingController();
  final TextEditingController socialInsuranceController =
      TextEditingController();
  final TextEditingController raisePercentageController =
      TextEditingController();

  SalaryCalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'salary_calculation'.tr,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                decoration: InputDecoration(
                  labelText: 'base_salary'.tr,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // Dismiss the keyboard
                    },
                  ),
                ),
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
                      Text("received_raise".tr),
                      Spacer(),
                      Switch(
                        value: controller.hasRaise.value,
                        // onChanged: (value) {
                        //   controller.toggleRaise(value);
                        // },
                        onChanged: controller.isMultiYearProjection.value
                            ? null // Disable the toggle when Multi-Year Projection is on
                            : (value) {
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
                        decoration: InputDecoration(
                          labelText: 'raise_percentage'.tr,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
                        onChanged: (value) {
                          controller.updateRaisePercentage(
                              double.tryParse(value) ?? 0.0);
                          if (controller.hasRaise.value) {
                            controller.isMultiYearProjection.value = false;
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context)
                              .unfocus(); // Dismiss the keyboard
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${'raise_amount'.tr}: ${'sar'.tr} ${controller.raiseAmount.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${'new_base_salary'.tr}: ${'sar'.tr} ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),

              const SizedBox(height: 10),

              // Multi-Year Projection Toggle
              Obx(() => Row(
                    children: [
                      Text("Calculate salary for multiple years?".tr),
                      Spacer(),
                      Switch(
                        value: controller.isMultiYearProjection.value,
                        onChanged: (value) {
                          controller.toggleMultiYearProjection(value);
                          if (controller.isMultiYearProjection.value) {
                            controller.hasRaise.value = false;
                            controller.clearRaiseFields();
                          }
                        },
                      ),
                    ],
                  )),
              const SizedBox(height: 10),

              // Multi-Year Projection Inputs (Visible if Toggle is On)
              Obx(() {
                if (controller.isMultiYearProjection.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number of Years Input
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Number of years (1-10)'.tr,
                        ),
                        onChanged: (value) {
                          final int years = int.tryParse(value) ?? 0;
                          if (years >= 1 && years <= 10) {
                            controller.updateNumberOfYears(years);
                          } else {
                            Get.snackbar(
                              'Invalid Input',
                              'Please enter a number between 1 and 10.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // First Promotion Year
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'First promotion year'.tr,
                        ),
                        onChanged: (value) {
                          controller.updateFirstPromotionYear(
                              int.tryParse(value) ?? 0);
                        },
                      ),
                      const SizedBox(height: 10),

                      // Promotion Interval
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Promotion interval (in years)'.tr,
                        ),
                        onChanged: (value) {
                          controller.updatePromotionInterval(
                              int.tryParse(value) ?? 0);
                          controller.updateDynamicFields();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Dynamically Generated Increment and Promotion Inputs
                      Obx(() {
                        return Column(
                          children: List.generate(
                            controller.dynamicInputs.length,
                            (index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    labelText:
                                        'Year ${controller.dynamicInputs[index].year} - Annual increment (%)'
                                            .tr,
                                  ),
                                  onChanged: (value) {
                                    controller.updateAnnualIncrementForYear(
                                      index,
                                      double.tryParse(value) ?? 0.0,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                if (controller
                                    .dynamicInputs[index].hasPromotion)
                                  TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText:
                                          'Year ${controller.dynamicInputs[index].year} - Promotion increment (%)'
                                              .tr,
                                    ),
                                    onChanged: (value) {
                                      controller
                                          .updatePromotionIncrementForYear(
                                        index,
                                        double.tryParse(value) ?? 0.0,
                                      );
                                    },
                                  ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      })

                      // Obx(() {
                      //   return Column(
                      //     children: List.generate(
                      //       controller.dynamicInputs.length,
                      //       (index) => Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           TextField(
                      //             keyboardType: TextInputType.numberWithOptions(
                      //                 decimal: true),
                      //             decoration: InputDecoration(
                      //               labelText:
                      //                   'Year ${controller.dynamicInputs[index].year} - Annual increment (%)'
                      //                       .tr,
                      //             ),
                      //             onChanged: (value) {
                      //               controller.updateAnnualIncrementForYear(
                      //                 index,
                      //                 double.tryParse(value) ?? 0.0,
                      //               );
                      //             },
                      //           ),
                      //           const SizedBox(height: 10),
                      //           if (controller
                      //               .dynamicInputs[index].hasPromotion)
                      //             TextField(
                      //               keyboardType:
                      //                   TextInputType.numberWithOptions(
                      //                       decimal: true),
                      //               decoration: InputDecoration(
                      //                 labelText:
                      //                     'Year ${controller.dynamicInputs[index].year} - Promotion increment (%)'
                      //                         .tr,
                      //               ),
                      //               onChanged: (value) {
                      //                 controller
                      //                     .updatePromotionIncrementForYear(
                      //                   index,
                      //                   double.tryParse(value) ?? 0.0,
                      //                 );
                      //               },
                      //             ),
                      //           const SizedBox(height: 10),
                      //         ],
                      //       ),
                      //     ),
                      //   );
                      // }),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
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
                        decoration: InputDecoration(
                          labelText: 'housing_allowance'.tr,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
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
                      "${'sar'.tr} ${controller.housingAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
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
                          labelText: 'transportation_allowance'.tr,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
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
                      "${'sar'.tr} ${controller.transportationAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
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
                        decoration: InputDecoration(
                          labelText: 'social_insurance'.tr,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
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
                      "${'sar'.tr} ${controller.socialSecurityAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
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
                                '${allowance.name}: ${allowance.type == AllowanceType.fixed ? "${'sar'.tr} ${allowance.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}" : "${allowance.percentageInput?.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}% → ${'sar'.tr} ${allowance.value}"}'),
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
              Obx(() => RepaintBoundary(
                    key: _resultsKey,
                    child: Container(
                      width: double.infinity, // Makes the box take full width
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200], // Darker shade for dark mode
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Conditional New Base Salary Display
                          _buildResultRow(
                            controller.hasRaise.value
                                ? 'new_base_salary'.tr
                                : 'base_salary'.tr,
                            '${'sar'.tr} ${controller.baseSalary.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                          _buildResultRow(
                            'housing_allowance_amount'.tr,
                            '${'sar'.tr} ${controller.housingAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                          _buildResultRow(
                            'transportation_allowance_amount'.tr,
                            '${'sar'.tr} ${controller.transportationAllowanceAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                          _buildResultRow(
                            'social_insurance_deduction_amount'.tr,
                            '${'sar'.tr} ${controller.socialSecurityAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                          ...controller.allowances
                              .map((allowance) => _buildResultRow(
                                    allowance.name,
                                    '${'sar'.tr} ${allowance.value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                                    isBold: true,
                                    context: context,
                                  )),
                          _buildResultRow(
                            'pre_deduction_total'.tr,
                            '${'sar'.tr} ${controller.preDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                          _buildResultRow(
                            'post_deduction_total'.tr,
                            '${'sar'.tr} ${controller.postDeductionTotal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                            isBold: true,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  )),

              SizedBox(height: 20),

              // Save Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.shareResults(_resultsKey),
                    child: Text('share_calculation'.tr),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.saveCalculation('Salary Calculation');
                    },
                    child: Text('save_calculation'.tr),
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

  Widget _buildResultRow(String label, String value,
      {bool isBold = false, required BuildContext context}) {
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black, // Adjust text color for dark mode
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, // Adjust text color for dark mode
            ),
          ),
        ],
      ),
    );
  }
}
