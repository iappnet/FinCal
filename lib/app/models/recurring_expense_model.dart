class RecurringExpenseModel {
  String title;
  double amount;
  int frequency; // 1, 2, 3, 4, or 6 (times per year)
  double monthlyAllocation;

  RecurringExpenseModel({
    required this.title,
    required this.amount,
    required this.frequency,
  }) : monthlyAllocation = _calculateMonthlyAllocation(amount, frequency);

  static double _calculateMonthlyAllocation(double amount, int frequency) {
    return amount / (12 / frequency);
  }
}
