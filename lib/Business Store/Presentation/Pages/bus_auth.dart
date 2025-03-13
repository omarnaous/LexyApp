import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart'; // Package to read Excel files
import 'package:lexyapp/Admin/Pages/salons_maage.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/main.dart';

class BusinessSignUp extends StatefulWidget {
  const BusinessSignUp({
    super.key,
    this.isAdmin,
  });
  final bool? isAdmin;

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

  bool isLoading = false;

  void _signUpBusinessUser(BuildContext context) async {
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
        isLoading = true;
      });

      await context.read<AuthCubit>().signUpBusinessUser(
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            businessOwnerName: businessOwnerName,
            context: context,
          );

      if (widget.isAdmin == true) {
        await context.read<AuthCubit>().signInWithEmail(
            "robertadmin@gmail.com", "RobertAdmin2025", context);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return const MainApp();
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully'),
            backgroundColor: Colors.purple,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return const SalonManagement();
          }),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  void _importExcelData() async {
    // Use FilePicker to select an Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      // Read the selected file
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Print the available table names (to help debug)
      excel.tables.forEach((key, value) {
        print('Table Name: $key');
      });

      // Access the first table by its name (change 'Sheet1' to your sheet name)
      var sheet =
          excel.tables['Sheet1']; // Replace 'Sheet1' with the actual sheet name

      if (sheet != null) {
        // Process the data from the Excel sheet
        for (var row in sheet.rows.skip(1)) {
          // Make sure each row has enough data
          if (row.length >= 4) {
            // Get the values of each cell as strings
            String email2 = row[2]?.value.toString() ?? '';
            String password2 = row[3]?.value.toString() ?? '';
            String businessOwnerName2 = row[0]?.value.toString() ?? '';
            String phoneNumber2 = row[1]?.value.toString() ?? '';

            // Print the values as strings
            print('Email: $email2');
            print('Password: $password2');
            print('Business Owner: $businessOwnerName2');
            print('Phone Number: $phoneNumber2');

            // Proceed to sign up if fields are not empty
            if (email2.isNotEmpty &&
                password2.isNotEmpty &&
                phoneNumber2.isNotEmpty) {
              await context.read<AuthCubit>().signUpBusinessUser(
                    // ignore: use_build_context_synchronously
                    context: context,
                    email: email2,
                    password: password2,
                    phoneNumber: phoneNumber2,
                    businessOwnerName: businessOwnerName2,
                  );
            }
          }
        }

        // Action to be done after the loop finishes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch Import Completed'),
            backgroundColor: Colors.green,
          ),
        );
        await context.read<AuthCubit>().signInWithEmail(
            "robertadmin@gmail.com", "RobertAdmin2025", context);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return const MainApp();
          }),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return const SalonManagement();
          }),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
          backgroundColor: Colors.red,
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
              isLoading = true;
            });
          } else {
            setState(() {
              isLoading = false;
            });

            if (state is AuthSuccess && widget.isAdmin == null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainApp()),
                (Route<dynamic> route) => false, // Remove all previous routes
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
                          const SizedBox(height: 24),
                          if (widget.isAdmin == true)
                            ElevatedButton(
                              onPressed: _importExcelData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text(
                                'Batch Import from Excel',
                                style: TextStyle(fontSize: 18),
                              ),
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
                  onPressed: () {
                    _signUpBusinessUser(context);
                  },
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
