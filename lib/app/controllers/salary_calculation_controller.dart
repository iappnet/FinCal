import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../models/allowance_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../models/calculation_model.dart';
import '../services/database_helper.dart';
import '../controllers/settings_controller.dart';

class SalaryCalculationController extends GetxController {
  // Reactive variables
  var baseSalary = 0.0.obs;
  var socialinsurancePercentage = 9.75.obs;
  var allowances = <Allowance>[].obs;
  var originalBaseSalary = 0.0.obs; // Keeps the unmodified base salary
  var hasRaise = false.obs; // Toggle for raise
  var raisePercentage = 0.0.obs; // Percentage input for raise
  var raiseAmount = 0.0.obs; // Calculated raise value

  // Allowance-specific percentages
  var housingAllowancePercentage = 25.0.obs;
  var transportationAllowancePercentage = 10.0.obs;

  // State for results box visibility
  var isResultsVisible = false.obs;

  // Calculated Values
  double get housingAllowanceAmount =>
      baseSalary.value * (housingAllowancePercentage.value / 100);

  double get transportationAllowanceAmount =>
      baseSalary.value * (transportationAllowancePercentage.value / 100);

  double get socialSecurityAmount =>
      (baseSalary.value + housingAllowanceAmount) *
      (socialinsurancePercentage.value / 100);

  double get preDeductionTotal {
    double customAllowancesTotal = allowances.fold(0.0, (sum, item) {
      if (item.type == AllowanceType.percentage) {
        // Calculate percentage-based allowance
        return sum + item.value;
      } else if (item.type == AllowanceType.percentageWithMinMax) {
        // Calculate allowance within min/max range
        double calculatedValue = item.value;
        double min = item.min ?? 0.0;
        double max = item.max ?? double.infinity;
        return sum + calculatedValue.clamp(min, max);
      } else {
        // Fixed allowance
        return sum + item.value;
      }
    });

    return baseSalary.value +
        housingAllowanceAmount +
        transportationAllowanceAmount +
        customAllowancesTotal;
  }

  double get postDeductionTotal => preDeductionTotal - socialSecurityAmount;

  void toggleRaise(bool value) {
    hasRaise.value = value;

    if (!value) {
      // Reset to original base salary when Raise is toggled off
      baseSalary.value = originalBaseSalary.value;
      raisePercentage.value = 0.0;
      raiseAmount.value = 0.0;
    }

    _updateResults();
  }

  void updateRaisePercentage(double percentage) {
    raisePercentage.value = percentage;

    // Always use the original base salary for calculations
    raiseAmount.value = originalBaseSalary.value * (percentage / 100);

    // Update the displayed base salary
    baseSalary.value = originalBaseSalary.value + raiseAmount.value;

    _updateResults();
  }

  // void _updateBaseSalaryWithRaise() {
  //   double newBaseSalary = baseSalary.value + raiseAmount.value;
  //   updateBaseSalary(newBaseSalary); // Reuse existing method
  // }

  // Update methods
  void updateBaseSalary(double value) {
    // Set original value whenever base salary is updated
    originalBaseSalary.value = value;
    baseSalary.value = value;

    // If raise is active, recalculate based on the raise percentage
    if (hasRaise.value && raisePercentage.value > 0) {
      updateRaisePercentage(raisePercentage.value);
    } else {
      _updateResults();
    }
  }

  void updatesocialinsurancePercentage(double value) {
    socialinsurancePercentage.value = value;
    _updateResults();
  }

  void updateHousingAllowance(double value) {
    housingAllowancePercentage.value = value;
    _updateResults();
  }

  void updateTransportationAllowance(double value) {
    transportationAllowancePercentage.value = value;
    _updateResults();
  }

  void _updateResults() {
    if (isResultsVisible.value) update();
  }

  // Calculate results (integrated for MainScreen)
  void calculateResults() {
    isResultsVisible.value = true;
    update();
  }

  void addAllowance(BuildContext context) {
    _showAllowanceBottomSheet(context);
  }

  void editAllowance(BuildContext context, int index) {
    _showAllowanceBottomSheet(context, index: index);
  }

  void _showAllowanceBottomSheet(BuildContext context, {int? index}) {
    final allowance = index != null
        ? allowances[index]
        : Allowance(name: "", value: 0.0, type: AllowanceType.fixed);

    final TextEditingController nameController =
        TextEditingController(text: allowance.name);
    final TextEditingController valueController = TextEditingController(
        text: allowance.value
            .toStringAsFixed(2)
            .replaceAll(RegExp(r'\.00$'), ''));
    final TextEditingController minController = TextEditingController(
        text: allowance.min
                ?.toStringAsFixed(2)
                .replaceAll(RegExp(r'\.00$'), '') ??
            "");
    final TextEditingController maxController = TextEditingController(
        text: allowance.max
                ?.toStringAsFixed(2)
                .replaceAll(RegExp(r'\.00$'), '') ??
            "");

    var selectedType = allowance.type.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Obx(() => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Allowance Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Allowance Name'),
                  ),
                  SizedBox(height: 10),

                  // Allowance Type Dropdown
                  DropdownButtonFormField<AllowanceType>(
                    value: selectedType.value,
                    items: AllowanceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedType.value = value;
                    },
                    decoration: InputDecoration(labelText: 'Allowance Type'),
                  ),
                  SizedBox(height: 10),

                  // Conditionally Render Allowance Fields
                  if (selectedType.value == AllowanceType.fixed)
                    TextField(
                      controller: valueController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Allowance Value'),
                    ),
                  if (selectedType.value == AllowanceType.percentage) ...[
                    TextField(
                      controller: valueController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: 'Allowance Percentage (%)'),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    Obx(() {
                      double percentageValue = baseSalary.value *
                          (double.tryParse(valueController.text) ?? 0.0) /
                          100;
                      return Text(
                        "Calculated Value: SAR ${percentageValue.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }),
                  ],

                  if (selectedType.value ==
                      AllowanceType.percentageWithMinMax) ...[
                    TextField(
                      controller: valueController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: 'Allowance Percentage (%)'),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: minController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Minimum Value'),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: maxController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Maximum Value'),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    Obx(() {
                      double percentageValue = baseSalary.value *
                          (double.tryParse(valueController.text) ?? 0.0) /
                          100;
                      double min = double.tryParse(minController.text) ?? 0.0;
                      double max = double.tryParse(maxController.text) ??
                          double.infinity;
                      percentageValue = percentageValue.clamp(min, max);

                      return Text(
                        "Calculated Value: SAR ${percentageValue.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }),
                  ],

                  SizedBox(height: 20),

                  // Save Changes Button
                  ElevatedButton(
                    onPressed: () {
                      double calculatedValue =
                          double.tryParse(valueController.text) ?? 0.0;

                      if (selectedType.value == AllowanceType.percentage) {
                        // Calculate percentage-based value
                        calculatedValue =
                            baseSalary.value * (calculatedValue / 100);
                      } else if (selectedType.value ==
                          AllowanceType.percentageWithMinMax) {
                        // Calculate percentage-based value and clamp it within min/max
                        double min = double.tryParse(minController.text) ?? 0.0;
                        double max = double.tryParse(maxController.text) ??
                            double.infinity;
                        calculatedValue =
                            (baseSalary.value * (calculatedValue / 100))
                                .clamp(min, max);
                      }

                      final newAllowance = Allowance(
                        name: nameController.text,
                        value: calculatedValue,
                        type: selectedType.value,
                        min: selectedType.value ==
                                AllowanceType.percentageWithMinMax
                            ? double.tryParse(minController.text) ?? 0.0
                            : null,
                        max: selectedType.value ==
                                AllowanceType.percentageWithMinMax
                            ? double.tryParse(maxController.text) ?? 0.0
                            : null,
                        percentageInput:
                            selectedType.value == AllowanceType.percentage ||
                                    selectedType.value ==
                                        AllowanceType.percentageWithMinMax
                                ? double.tryParse(valueController.text) ?? 0.0
                                : null, // Store the user's input percentage
                      );
                      if (index != null) {
                        allowances[index] = newAllowance;
                      } else {
                        allowances.add(newAllowance);
                      }
                      Navigator.pop(context);
                      update();
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> saveCalculation(String calculationType) async {
    final details = {
      'Base Salary': baseSalary.value,
      'Housing Allowance': housingAllowanceAmount,
      'Transportation Allowance': transportationAllowanceAmount,
      'Custom Allowances': allowances
          .map((a) => {
                'Name': a.name,
                'Value': a.value,
                'Type': a.type.toString(),
              })
          .toList(),
      'Social Insurance Deduction': socialSecurityAmount,
      'Pre-Deduction Total': preDeductionTotal,
      'Post-Deduction Total': postDeductionTotal,
    };

    final calculation = CalculationModel(
      calculationType: calculationType,
      details: details,
      date: DateTime.now(),
    );

    await DatabaseHelper().insertCalculation(calculation);
    Get.snackbar('Success', '$calculationType saved successfully!');
  }

  Future<void> fetchSavedCalculations() async {
    final calculations = await DatabaseHelper().fetchCalculations();
    for (var calc in calculations) {
      if (kDebugMode) {
        print(
            'ID: ${calc.id}, Type: ${calc.calculationType}, Details: ${calc.details}');
      }
    }
  }

  Future<void> shareResults(GlobalKey repaintBoundaryKey) async {
    try {
      // Access the SettingsController to read the auto-save preference
      final settingsController = Get.find<SettingsController>();
      final autoSaveEnabled = settingsController.isAutoSaveImage.value;
      // Check user preference for auto-save

      // Generate PDF
      final pdfPath = await saveResultsAsPDF();

      // Generate JPEG
      String? jpgPath;
      if (autoSaveEnabled == 'true') {
        jpgPath = await saveResultsAsJPEG(repaintBoundaryKey, autoSave: true);
      } else {
        jpgPath = await saveResultsAsJPEG(repaintBoundaryKey, autoSave: false);
      }

      // Generate Text
      final textDetails = '''
Salary Calculation Report
----------------------------
Base Salary: SAR ${baseSalary.value.toStringAsFixed(2)}
Housing Allowance: SAR ${housingAllowanceAmount.toStringAsFixed(2)}
Transportation Allowance: SAR ${transportationAllowanceAmount.toStringAsFixed(2)}
Social Security Deduction: SAR ${socialSecurityAmount.toStringAsFixed(2)}
Pre-Deduction Total: SAR ${preDeductionTotal.toStringAsFixed(2)}
Post-Deduction Total: SAR ${postDeductionTotal.toStringAsFixed(2)}

Generated on: ${DateTime.now().toLocal()}
''';

      // // Prepare files for sharing
      // final files = <XFile>[
      //   XFile(pdfPath, name: 'Calculation_Report.pdf'),
      //   if (jpgPath != null) XFile(jpgPath, name: 'Calculation_Report.jpg'),
      // ];

      // // Show Share Sheet
      // Share.shareXFiles(
      //   files,
      //   text: textDetails,
      // );

      // Show dialog for user to choose action
      await Get.defaultDialog(
        title: "Share Calculation",
        content: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Share as text
                Share.share(textDetails, subject: "Salary Calculation Report");
                Get.back(); // Close dialog
              },
              child: Text("Share as Text"),
            ),
            ElevatedButton(
              onPressed: () {
                // Copy text to clipboard
                Clipboard.setData(ClipboardData(text: textDetails));
                Get.snackbar(
                    "Copied", "Calculation details copied to clipboard");
                Get.back(); // Close dialog
              },
              child: Text("Copy to Clipboard"),
            ),
            ElevatedButton(
              onPressed: () {
                // Share files (PDF and/or JPEG)
                final files = <XFile>[
                  XFile(pdfPath, name: 'Calculation_Report.pdf'),
                  if (jpgPath != null)
                    XFile(jpgPath, name: 'Calculation_Report.jpg'),
                ];
                Share.shareXFiles(
                  files,
                  text: textDetails,
                );
                Get.back(); // Close dialog
              },
              child: Text("Share Files"),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while sharing: $e');
    }
  }

  Future<String> saveResultsAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Salary Calculation Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(children: [
                  pw.Text('Description',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Amount (SAR)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Base Salary'),
                  pw.Text(baseSalary.value.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Housing Allowance'),
                  pw.Text(housingAllowanceAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Transportation Allowance'),
                  pw.Text(transportationAllowanceAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Social Security Deduction'),
                  pw.Text(socialSecurityAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Pre-Deduction Total'),
                  pw.Text(preDeductionTotal.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('Post-Deduction Total'),
                  pw.Text(postDeductionTotal.toStringAsFixed(2)),
                ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateTime.now().toLocal()}',
              style: pw.TextStyle(
                  fontSize: 12, color: PdfColor.fromHex('#888888')),
            ),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Calculation_Report.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<String?> saveResultsAsJPEG(GlobalKey repaintBoundaryKey,
      {bool autoSave = false}) async {
    try {
      // Capture the image
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      if (autoSave) {
        // Save the image to Photos
        final result =
            await ImageGallerySaver.saveImage(pngBytes, quality: 100);
        bool success = result['isSuccess'] ?? false;

        if (success) {
          Get.snackbar('Success', 'Image saved to Photos successfully.');
          return result['filePath'] ?? result['file'];
        } else {
          Get.snackbar('Error', 'Failed to save the image.');
          return null;
        }
      } else {
        // Save the image temporarily
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/Calculation_Report.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        return filePath;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while saving JPEG: $e');
      return null;
    }
  }
}
