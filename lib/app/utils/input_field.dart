import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>?
      inputFormatters; // Changed to List<TextInputFormatter>
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const InputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters, // Accepts a list of input formatters
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // Apply the input formatters
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // hintText: 'Enter $label',
            errorText: validator?.call(controller.text),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
