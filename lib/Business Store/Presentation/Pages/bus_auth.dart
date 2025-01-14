import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/main.dart';
import 'package:phone_form_field/phone_form_field.dart';

class BusinessSignUp extends StatefulWidget {
  const BusinessSignUp({super.key});

  @override
  State<BusinessSignUp> createState() => _BusinessSignUpState();
}

class _BusinessSignUpState extends State<BusinessSignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController businessOwnerController = TextEditingController();
  final PhoneController phoneController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.LB, nsn: ''),
  );

  bool isLoading = false; // State to handle loading

  void _signUpBusinessUser(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final businessOwnerName = businessOwnerController.text.trim();
      final phoneNumber = phoneController.value.international;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.purple,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true; // Show loading
      });

      context.read<AuthCubit>().signUpBusinessUser(
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            businessOwnerName: businessOwnerName,
            context: context,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Sign Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              isLoading = true; // Show loading
            });
          } else {
            setState(() {
              isLoading = false; // Hide loading
            });

            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainApp()),
              );
              context.read<NavBarCubit>().showNavBar();
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          CustomTextField(
                            controller: businessOwnerController,
                            labelText: 'Business Owner',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Business Owner is required'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          PhoneFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            defaultCountry: IsoCode.LB,
                            validator: (phoneNumber) =>
                                phoneNumber == null || phoneNumber.nsn.isEmpty
                                    ? 'Phone Number is required'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: emailController,
                            labelText: 'Email',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              return emailRegex.hasMatch(value)
                                  ? null
                                  : 'Enter a valid email address';
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: passwordController,
                            labelText: 'Password',
                            obscureText: true,
                            maxLines: 1,
                            validator: (value) =>
                                value == null || value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: confirmPasswordController,
                            labelText: 'Confirm Password',
                            obscureText: true,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size.fromHeight(60),
                  ),
                  onPressed: () => _signUpBusinessUser(context),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
