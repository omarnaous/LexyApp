import 'package:flutter/material.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Logic/phone_service.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/code_verifcation.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PhoneNumberInputScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PhoneController phoneController = PhoneController(
    initialValue: const PhoneNumber(
      isoCode: IsoCode.LB,
      nsn: '',
    ),
  ); // Initialize the controller

  PhoneNumberInputScreen({super.key});

  String? validateNotEmpty(PhoneNumber? phoneNumber, {String? errorText}) {
    if (phoneNumber == null || phoneNumber.nsn.isEmpty) {
      return errorText ?? 'Phone number cannot be empty';
    }
    return null;
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final phoneNumber = phoneController.value;
      final fullPhoneNumber = '+${phoneNumber.countryCode}${phoneNumber.nsn}';

      PhoneAuthService().sendVerificationCode(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          showCustomSnackBar(
            context,
            'Verification Sent',
            'OTP sent successfully to $fullPhoneNumber',
          );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return OtpVerificationScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              );
            },
          ));
        },
        onVerificationFailed: (error) {
          showCustomSnackBar(
            context,
            'Verification Failed',
            error.message ?? 'Something went wrong',
            isError: true,
          );
        },
        onTimeout: (verificationId) {
          showCustomSnackBar(
            context,
            'Timeout',
            'OTP request timed out. Please try again.',
            isError: true,
          );
        },
      );
    } else {
      showCustomSnackBar(
        context,
        'Invalid Input',
        'Please provide a valid phone number.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Input'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400), // Adjust height
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PhoneFormField(
                    controller: phoneController, // Use the controller
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    defaultCountry: IsoCode.LB,
                    validator: (phoneNumber) => validateNotEmpty(
                      phoneNumber,
                      errorText: 'Phone number cannot be empty',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Verify Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
