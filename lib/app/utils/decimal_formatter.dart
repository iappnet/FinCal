import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Regular expression to allow numbers with optional decimal places
    final regExp = RegExp(r'^\d+(\.\d{0,2})?$');

    if (text.isEmpty || regExp.hasMatch(text)) {
      return newValue;
    }

    return oldValue; // Revert to the previous valid value if invalid
  }
}
