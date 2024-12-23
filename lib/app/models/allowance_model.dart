import 'package:get/get.dart';

class Allowance {
  String name;
  double value;
  AllowanceType type;
  double? min;
  double? max;
  double? percentageInput; // New field to store user input percentage

  Allowance({
    required this.name,
    required this.value,
    required this.type,
    this.min,
    this.max,
    this.percentageInput,
  });
}

enum AllowanceType { fixed, percentage, percentageWithMinMax }

// Helper to get localized strings for AllowanceType
String getAllowanceTypeString(AllowanceType type) {
  switch (type) {
    case AllowanceType.fixed:
      return 'allowance_type_fixed'.tr;
    case AllowanceType.percentage:
      return 'allowance_type_percentage'.tr;
    case AllowanceType.percentageWithMinMax:
      return 'allowance_type_percentage_with_min_max'.tr;
  }
}
