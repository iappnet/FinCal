import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:pdf/pdf.dart';
import '../models/allowance_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
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
                    decoration: InputDecoration(labelText: 'allowance_name'.tr),
                  ),
                  SizedBox(height: 10),

                  // Allowance Type Dropdown
                  DropdownButtonFormField<AllowanceType>(
                    value: selectedType.value,
                    items: AllowanceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(getAllowanceTypeString(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedType.value = value;
                    },
                    decoration: InputDecoration(labelText: 'allowance_type'.tr),
                  ),

                  SizedBox(height: 10),

                  // Conditionally Render Allowance Fields
                  if (selectedType.value == AllowanceType.fixed)
                    TextField(
                      controller: valueController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: 'allowance_value'.tr),
                    ),
                  if (selectedType.value == AllowanceType.percentage) ...[
                    TextField(
                      controller: valueController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: 'allowance_percentage'.tr),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    Obx(() {
                      double percentageValue = baseSalary.value *
                          (double.tryParse(valueController.text) ?? 0.0) /
                          100;
                      return Text(
                        '${'calculated_value'.tr}: ${'SAR'.tr} ${percentageValue.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
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
                      decoration:
                          InputDecoration(labelText: 'allowance_percentage'.tr),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: minController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: 'minimum_value'.tr),
                      onChanged: (value) {
                        update();
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: maxController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: 'maximum_value'.tr),
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
                        '${'calculated_value'.tr}: ${'SAR'.tr} ${percentageValue.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
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
                    child: Text('save_changes'.tr),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> saveCalculation(String calculationType) async {
    final details = {
      'base_salary'.tr: baseSalary.value,
      'housing_allowance'.tr: housingAllowanceAmount,
      'transportation_allowance'.tr: transportationAllowanceAmount,
      'custom_allowances'.tr: allowances
          .map((a) => {
                'name'.tr: a.name,
                'value'.tr: a.value,
                'type'.tr: a.type.toString(),
              })
          .toList(),
      'social_insurance_deduction'.tr: socialSecurityAmount,
      'pre_deduction_total'.tr: preDeductionTotal,
      'post_deduction_total'.tr: postDeductionTotal,
    };

    final calculation = CalculationModel(
      calculationType: calculationType,
      details: details,
      date: DateTime.now(),
    );

    await DatabaseHelper().insertCalculation(calculation);
    Get.snackbar(
        'success'.tr, '${'calculation_saved_success'.tr} $calculationType!');
  }

  Future<void> shareResults(GlobalKey repaintBoundaryKey) async {
    try {
      final settingsController = Get.find<SettingsController>();
      final autoSaveEnabled = settingsController.isAutoSaveImage.value;

      final pdfPath = await saveResultsAsPDF();

      String? jpgPath;
      if (autoSaveEnabled) {
        jpgPath = await saveResultsAsJPEG(repaintBoundaryKey, autoSave: true);
      } else {
        jpgPath = await saveResultsAsJPEG(repaintBoundaryKey, autoSave: false);
      }

      final textDetails = '''
${'salary_calculation_report'.tr}
----------------------------
${'base_salary'.tr}: ${'SAR'.tr} ${baseSalary.value.toStringAsFixed(2)}
${'housing_allowance'.tr}: ${'SAR'.tr} ${housingAllowanceAmount.toStringAsFixed(2)}
${'transportation_allowance'.tr}: ${'SAR'.tr} ${transportationAllowanceAmount.toStringAsFixed(2)}
${'social_insurance_deduction'.tr}: ${'SAR'.tr} ${socialSecurityAmount.toStringAsFixed(2)}
${'pre_deduction_total'.tr}: ${'SAR'.tr} ${preDeductionTotal.toStringAsFixed(2)}
${'post_deduction_total'.tr}: ${'SAR'.tr} ${postDeductionTotal.toStringAsFixed(2)}

${'generated_on'.tr}: ${DateTime.now().toLocal()}
''';

      await Get.defaultDialog(
        title: "share_calculation".tr,
        content: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Share.share(textDetails,
                    subject: "salary_calculation_report".tr);
                Get.back();
              },
              child: Text("share_as_text".tr),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: textDetails));
                Get.snackbar("copied".tr, "calculation_copied_clipboard".tr);
                Get.back();
              },
              child: Text("copy_to_clipboard".tr),
            ),
            ElevatedButton(
              onPressed: () {
                final files = <XFile>[
                  XFile(pdfPath, name: 'Calculation_Report.pdf'),
                  if (jpgPath != null)
                    XFile(jpgPath, name: 'Calculation_Report.jpg'),
                ];
                Share.shareXFiles(
                  files,
                  text: textDetails,
                );
                Get.back();
              },
              child: Text("share_files".tr),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_occurred_sharing'.tr}: $e');
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
              'salary_calculation_report'.tr,
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
                  pw.Text('description'.tr,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('amount_sar'.tr,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]),
                pw.TableRow(children: [
                  pw.Text('base_salary'.tr),
                  pw.Text(baseSalary.value.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('housing_allowance'.tr),
                  pw.Text(housingAllowanceAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('transportation_allowance'.tr),
                  pw.Text(transportationAllowanceAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('social_insurance_deduction'.tr),
                  pw.Text(socialSecurityAmount.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('pre_deduction_total'.tr),
                  pw.Text(preDeductionTotal.toStringAsFixed(2)),
                ]),
                pw.TableRow(children: [
                  pw.Text('post_deduction_total'.tr),
                  pw.Text(postDeductionTotal.toStringAsFixed(2)),
                ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              '${'generated_on'.tr}: ${DateTime.now().toLocal()}',
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
            await ImageGallerySaverPlus.saveImage(pngBytes, quality: 100);
        bool success = result['isSuccess'] ?? false;

        if (success) {
          Get.snackbar(
            'success'.tr,
            'image_saved_photos'.tr,
          );
          return result['filePath'] ?? result['file'];
        } else {
          Get.snackbar(
            'error'.tr,
            'failed_save_image'.tr,
          );
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
      Get.snackbar(
        'error'.tr,
        '${'error_saving_image'.tr}: $e',
      );
      return null;
    }
  }
}
