import 'package:get/get.dart';
import '../controllers/salary_calculation_controller.dart';

class SalaryCalculationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SalaryCalculationController());

    // Get.lazyPut<SalaryCalculationController>(
    //     () => SalaryCalculationController());
  }
}
