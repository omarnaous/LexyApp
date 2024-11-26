import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final VoidCallback? onTap; // Add onTap property

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.readOnly = false,
    this.validator,
    this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      validator: validator,
      onTap: onTap, // Assign onTap to TextFormField
    );
  }
}
