import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Features/Authentication/Business Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/User Profile Management/Logic/profile_mgt_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/phone_input.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/general_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('User is not authenticated'));
    }

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is AuthSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Edit Profile',
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _onBackPressed, // Custom back button function
              ),
            ),
            body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Something went wrong! ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User not found'));
                }

                final userData = snapshot.data!.data();
                if (userData == null) {
                  return const Center(child: Text('No user data found'));
                }

                final userModel = UserModel.fromMap(userData);

                _firstNameController.text = userModel.firstName;
                _lastNameController.text = userModel.lastName ?? '';
                _mobileNumberController.text = userModel.phoneNumber;
                _emailController.text = userModel.email;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) {
                          //       return PhoneNumberInputScreen();
                          //     },
                          //   ));
                          // },
                          controller: _mobileNumberController,
                          labelText: 'Mobile Number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        final userModel = UserModel(
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          phoneNumber: _mobileNumberController.text,
                          email: _emailController.text,
                          appointments: [], // Or user-specific logic
                          favourites: [],
                          imageUrl: '',
                          password: '',
                        );
                        _onSavePressed(userModel);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _onSavePressed(UserModel userModel2) {
    if (_formKey.currentState!.validate()) {
      final userModel = UserModel(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _mobileNumberController.text,
          email: _emailController.text,
          appointments: [],
          favourites: userModel2.favourites,
          imageUrl: userModel2.imageUrl,
          password: userModel2.password);

      final profileManagementCubit = context.read<ProfileManagementCubit>();

      profileManagementCubit.updateUserData(userModel).then((_) {
        showCustomSnackBar(context, 'Profile Updated!',
            'Your profile changes have been saved successfully.');
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      });
    }
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
    context.read<NavBarCubit>().showNavBar();
  }
}
