import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/manual_signup.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:lexyapp/main.dart';

class EmailForm extends StatefulWidget {
  const EmailForm({super.key});

  @override
  State<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _onContinuePressed() {
    if (_formKey.currentState!.validate()) {
      showCustomModalBottomSheet(
          context,
          SignUpForm(
            email: _emailController.text,
          ), () {
        Navigator.of(context).pop();
      }, showBackButton: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email address',
              labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Color(0xFFBDBDBD), // Equivalent to Colors.grey.shade400
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              // Email validation regex
              final RegExp emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Spacing before button
          SizedBox(
            height: 56, // Set a fixed height for the button
            width: double.infinity, // Full width of the parent
            child: ElevatedButton(
              onPressed: _onContinuePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Set background to black
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Set border radius to 10
                ),
              ),
              child: Text(
                'Continue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
