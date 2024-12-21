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

  void fetchCalculations() async {
    isLoading.value = true;
    final db = DatabaseHelper();
    calculations.value = await db.fetchCalculations();
    isLoading.value = false;
  }

  void deleteCalculation(int id) async {
    final db = DatabaseHelper();
    await db.deleteCalculation(id);
    fetchCalculations();
    Get.snackbar('Success', 'Calculation deleted successfully!');
  }

  void viewCalculationDetails(CalculationModel calculation) {
    Get.toNamed('/calculation-details', arguments: calculation);
  }
}
