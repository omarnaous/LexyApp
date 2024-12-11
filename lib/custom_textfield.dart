// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final VoidCallback? onTap; // Add onTap property
  final int? maxLines; // Add maxLines property
  final TextInputType keyboardType; // Add keyboardType property
  final bool? obscureText;
  final void Function(String)? onSubmitted; // Add onSubmitted property

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.readOnly = false,
    this.validator,
    this.onTap,
    this.maxLines,
    this.keyboardType = TextInputType.text, // Default to text keyboard
    this.obscureText,
    this.onSubmitted, // Initialize onSubmitted
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText ?? false,
      maxLines: maxLines, // Set maxLines for the TextFormField
      keyboardType: keyboardType, // Set the keyboard type
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
      onFieldSubmitted: onSubmitted, // Assign onSubmitted to TextFormField
    );
  }
}
