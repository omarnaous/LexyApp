import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/main.dart';
import 'package:phone_form_field/phone_form_field.dart';

class SignUpForm extends StatefulWidget {
  final String email;
  const SignUpForm({
    super.key,
    required this.email,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Define a variable to hold the phone number value
  PhoneNumber? phoneNumber;

  void _onContinuePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (phoneNumber != null) {
        final formattedPhoneNumber =
            '+${phoneNumber?.countryCode ?? ''}${phoneNumber?.nsn ?? ''}';

        context.read<AuthCubit>().signUpWithEmail(
              email: widget.email,
              password: passwordController.text,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              phoneNumber: formattedPhoneNumber,
            );
      } else {
        showCustomSnackBar(
            context, "Invalid Input", "Please enter a valid phone number",
            isError: true);
      }
    }
  }

  void showCustomSnackBar(BuildContext context, String title, String message,
      {bool isError = false}) {
    Color backgroundColor = isError ? Colors.deepPurple : Colors.black;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showCustomSnackBar(context, "Sign Up Failed", state.error,
              isError: true);
        } else if (state is AuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16, color: Colors.grey.shade700),
                    children: [
                      const TextSpan(text: "You’re almost there. "),
                      const TextSpan(text: "Create your account using "),
                      TextSpan(
                        text: widget.email,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey.shade700),
                      ),
                      const TextSpan(text: " by completing these details."),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField("First Name", firstNameController),
                _buildTextField("Last Name", lastNameController),
                _buildTextField("Password", passwordController,
                    isPassword: true),
                const SizedBox(height: 16),
                Text(
                  "Mobile Number",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                PhoneFormField(
                  initialValue: PhoneNumber.parse('+961'), // Lebanon as default
                  countrySelectorNavigator:
                      const CountrySelectorNavigator.page(),
                  onChanged: (number) {
                    setState(() {
                      phoneNumber = number;
                    });
                  },
                  countryButtonStyle: const CountryButtonStyle(
                    showDialCode: true,
                    showIsoCode: false,
                    showFlag: true,
                    flagSize: 16,
                  ),
                  decoration: const InputDecoration(
                    // labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                            0xFFBDBDBD), // Equivalent to Colors.grey.shade400
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
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onContinuePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          labelText: label,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
          // obscureText: isPassword,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
