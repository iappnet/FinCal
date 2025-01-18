import 'package:fincals/app/models/expense_model.dart';
import 'package:fincals/app/models/recurring_expense_model.dart';
import 'package:fincals/app/services/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PersonalFinanceController extends GetxController {
  var monthlyIncome = 0.0.obs;
  var additionalIncome = 0.0.obs;
  final RxList<ExpenseModel> fixedExpenses = <ExpenseModel>[].obs;
  var recurringExpenses = <RecurringExpenseModel>[].obs;
  var emergencySavings = 0.0.obs;
  var investments = 0.0.obs;

  double get remainingBalanceAfterSavings =>
      remainingBalanceAfterRecurring -
      emergencySavings.value -
      investments.value;

  final dbHelper = DatabaseHelper();
  bool get showSummary => true; // or your logic to determine the value

  // Lists to manage controllers for each expense
  final List<TextEditingController> titleControllers = [];
  final List<TextEditingController> amountControllers = [];
  // Lists to manage controllers for recurring expenses
  final List<TextEditingController> recurringTitleControllers = [];
  final List<TextEditingController> recurringAmountControllers = [];
  final List<TextEditingController> recurringFrequencyControllers = [];

  // Initialize controllers for existing expenses
  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    loadAllData();
    _syncRecurringControllers(); // Ensure controllers are initialized
  }

  void _initializeControllers() {
    titleControllers.clear();
    amountControllers.clear();
    for (var expense in fixedExpenses) {
      titleControllers.add(TextEditingController(text: expense.title));
      amountControllers
          .add(TextEditingController(text: expense.amount.toString()));
    }
  }

  void _syncRecurringControllers() {
    // Clear existing controllers
    recurringTitleControllers.clear();
    recurringAmountControllers.clear();
    recurringFrequencyControllers.clear();

    // Ensure controllers match the `recurringExpenses` list
    for (var expense in recurringExpenses) {
      recurringTitleControllers.add(TextEditingController(text: expense.title));
      recurringAmountControllers
          .add(TextEditingController(text: expense.amount.toString()));
      recurringFrequencyControllers
          .add(TextEditingController(text: expense.frequency.toString()));
    }
  }

  void addRecurringExpense(String title, double amount, int frequency) {
    // Add new expense to the list
    recurringExpenses.add(
      RecurringExpenseModel(title: title, amount: amount, frequency: frequency),
    );

    // Add corresponding controllers
    recurringTitleControllers.add(TextEditingController(text: title));
    recurringAmountControllers
        .add(TextEditingController(text: amount.toString()));
    recurringFrequencyControllers
        .add(TextEditingController(text: frequency.toString()));
  }

  void removeRecurringExpense(int index) {
    recurringExpenses.removeAt(index);

    // Dispose of and remove controllers
    recurringTitleControllers[index].dispose();
    recurringAmountControllers[index].dispose();
    recurringFrequencyControllers[index].dispose();

    recurringTitleControllers.removeAt(index);
    recurringAmountControllers.removeAt(index);
    recurringFrequencyControllers.removeAt(index);
  }

  void updateRecurringExpense(
      int index, String title, double amount, int frequency) {
    recurringExpenses[index] = RecurringExpenseModel(
        title: title, amount: amount, frequency: frequency);
    recurringExpenses.refresh();
  }

  // Add a new expense
  void addExpense(String title, double amount) {
    // Add new expense to the list
    fixedExpenses.add(ExpenseModel(title: title, amount: amount));
    // Create controllers for the new expense
    titleControllers.add(TextEditingController(text: title));
    amountControllers.add(TextEditingController(text: amount.toString()));
  }

  // Remove an expense
  void removeExpense(int index) {
    fixedExpenses.removeAt(index);
    // Remove the associated controllers and dispose of them
    titleControllers[index].dispose();
    amountControllers[index].dispose();
    titleControllers.removeAt(index);
    amountControllers.removeAt(index);
  }

  // Update an expense
  void updateExpense(int index, String title, double amount) {
    fixedExpenses[index] = ExpenseModel(title: title, amount: amount);
    // fixedExpenses.refresh(); // Notify observers of the update
  }

  void refreshControllers() {
    _initializeControllers();
  }

  @override
  void onClose() {
    // Dispose of all controllers when the controller is closed
    for (var controller in titleControllers) {
      controller.dispose();
    }
    for (var controller in amountControllers) {
      controller.dispose();
    }
    for (var controller in recurringTitleControllers) {
      controller.dispose();
    }
    for (var controller in recurringAmountControllers) {
      controller.dispose();
    }
    for (var controller in recurringFrequencyControllers) {
      controller.dispose();
    }

    super.onClose();
  }

  Future<void> loadAllData() async {
    final income = await dbHelper.fetchIncome();
    if (income != null) {
      monthlyIncome.value = income['monthlyIncome'];
      additionalIncome.value = income['additionalIncome'];
    }

    final fixed = await dbHelper.fetchFixedExpenses();
    fixedExpenses.assignAll(fixed
        .map((e) => ExpenseModel(title: e['title'], amount: e['amount']))
        .toList());

    final recurring = await dbHelper.fetchRecurringExpenses();
    recurringExpenses.assignAll(recurring.map((e) {
      return RecurringExpenseModel(
        title: e['title'],
        amount: e['amount'],
        frequency: e['frequency'],
      );
    }).toList());

    final savings = await dbHelper.fetchSavings();
    if (savings != null) {
      emergencySavings.value = savings['emergencySavings'];
      investments.value = savings['investments'];
    }

    // Synchronize controllers after fetching data
    _syncRecurringControllers();
  }

  // Save data
  Future<void> saveIncome() async {
    await dbHelper.saveIncome(monthlyIncome.value, additionalIncome.value);
  }

  Future<void> saveFixedExpenses() async {
    final expenses = fixedExpenses
        .map((e) => {'title': e.title, 'amount': e.amount})
        .toList();
    await dbHelper.saveFixedExpenses(expenses);
  }

  Future<void> saveRecurringExpenses() async {
    final expenses = recurringExpenses.map((e) {
      return {'title': e.title, 'amount': e.amount, 'frequency': e.frequency};
    }).toList();
    await dbHelper.saveRecurringExpenses(expenses);
  }

  Future<void> saveSavings() async {
    await dbHelper.saveSavings(emergencySavings.value, investments.value);
  }

  void updateEmergencySavings(String value) {
    emergencySavings.value = double.tryParse(value) ?? 0.0;
  }

  void updateInvestments(String value) {
    investments.value = double.tryParse(value) ?? 0.0;
  }

  double get totalIncome => monthlyIncome.value + additionalIncome.value;

  double get totalFixedExpenses =>
      fixedExpenses.fold(0, (sum, item) => sum + item.amount);

  double get remainingBalanceAfterFixed => totalIncome - totalFixedExpenses;

  double get totalAnnualRecurringExpenses =>
      recurringExpenses.fold(0, (sum, item) => sum + item.amount);

  double get totalMonthlyRecurringExpenses =>
      recurringExpenses.fold(0, (sum, item) => sum + item.monthlyAllocation);

  double get remainingBalanceAfterRecurring =>
      remainingBalanceAfterFixed - totalMonthlyRecurringExpenses;

  // void addRecurringExpense(String title, double amount, int frequency) {
  //   recurringExpenses.add(
  //     RecurringExpenseModel(title: title, amount: amount, frequency: frequency),
  //   );
  // }

  // void removeRecurringExpense(int index) {
  //   recurringExpenses.removeAt(index);
  // }

  // void updateRecurringExpense(
  //     int index, String title, double amount, int frequency) {
  //   recurringExpenses[index] = RecurringExpenseModel(
  //       title: title, amount: amount, frequency: frequency);
  //   recurringExpenses.refresh();
  // }

  void updateMonthlyIncome(String value) {
    if (value.isNumeric()) {
      monthlyIncome.value = double.tryParse(value) ?? 0.0;
    }
  }

  void updateAdditionalIncome(String value) {
    if (value.isNumeric()) {
      additionalIncome.value = double.tryParse(value) ?? 0.0;
    }
  }
}

extension StringExtension on String {
  bool isNumeric() {
    if (isEmpty) return false;
    final number = num.tryParse(this);
    return number != null;
  }
}
