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
