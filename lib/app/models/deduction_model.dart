class Deductions {
  double socialinsurancePercentage;
  double baseSalaryDeduction;
  double housingDeduction;

  Deductions({
    required this.socialinsurancePercentage,
    required this.baseSalaryDeduction,
    required this.housingDeduction,
  });

  // Extend for multi-year calculations
  Map<String, dynamic> toMap() {
    return {
      'socialinsurancePercentage': socialinsurancePercentage,
      'baseSalaryDeduction': baseSalaryDeduction,
      'housingDeduction': housingDeduction,
    };
  }

  static Deductions fromMap(Map<String, dynamic> map) {
    return Deductions(
      socialinsurancePercentage: map['socialinsurancePercentage'] as double,
      baseSalaryDeduction: map['baseSalaryDeduction'] as double,
      housingDeduction: map['housingDeduction'] as double,
    );
  }
}

// class Deductions {
//   double socialinsurancePercentage;
//   double baseSalaryDeduction;
//   double housingDeduction;

//   Deductions({
//     required this.socialinsurancePercentage,
//     required this.baseSalaryDeduction,
//     required this.housingDeduction,
//   });
// }
