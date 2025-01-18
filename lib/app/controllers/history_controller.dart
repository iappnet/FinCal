import 'package:get/get.dart';
import '../models/calculation_model.dart';
import '../services/database_helper.dart';

class HistoryController extends GetxController {
  var calculations = <CalculationModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCalculations();
  }

  @override
  void onReady() {
    super.onReady();
    fetchCalculations();
  }

  void fetchCalculations() async {
    isLoading.value = true;
    try {
      final db = DatabaseHelper();
      // Use the new fetchSalaryCalculations method
      final data = await db.fetchSalaryCalculations();
      calculations.assignAll(data); // Update the observable list
    } catch (e) {
      print("Error in fetchCalculations: $e");
      Get.snackbar('Error', 'Failed to fetch salary calculations');
    } finally {
      isLoading.value = false;
    }
  }

  // void fetchCalculations() async {
  //   isLoading.value = true;
  //   try {
  //     final db = DatabaseHelper();
  //     final data = await db.fetchCalculations();
  //     calculations.assignAll(data); // Update the observable list
  //   } catch (e) {
  //     print("Error in fetchCalculations: $e");
  //     Get.snackbar('Error', 'Failed to fetch calculations');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void addCalculation(CalculationModel calculation) async {
    final db = DatabaseHelper();
    await db.insertCalculation(calculation);
    fetchCalculations(); // Refresh list immediately
    Get.snackbar('Success', 'Calculation saved successfully!');
  }

  void deleteCalculation(int id) async {
    final db = DatabaseHelper();
    await db.deleteCalculation(id);
    fetchCalculations(); // Refresh list immediately
    Get.snackbar('Success', 'Calculation deleted successfully!');
  }

  void viewCalculationDetails(CalculationModel calculation) {
    Get.toNamed('/calculation-details', arguments: calculation);
  }
}
