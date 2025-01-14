import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/main.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _updateUserData(String field, String value) async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({field: value});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field updated successfully.')),
      );
    } catch (e) {
      debugPrint('Error updating $field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $field.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .delete();

      await currentUser!.delete();

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('User data not found.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String email = data['email'] ?? '';
          phoneNumberController.text = data['phoneNumber'] ?? '';
          ownerNameController.text = data['businessOwnerName'] ?? '';
          emailController.text = email;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email as a CustomTextField (non-editable)
                CustomTextField(
                  controller: emailController,
                  labelText: 'Email',
                  readOnly: true,
                  // enabled: false, // Making it non-editable
                ),
                const SizedBox(height: 16),
                const Text(
                  'Business Owner Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: ownerNameController,
                  labelText: 'Enter Owner Name',
                  onSubmitted: (value) =>
                      _updateUserData('businessOwnerName', value),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: phoneNumberController,
                  labelText: 'Enter Phone Number',
                  onSubmitted: (value) => _updateUserData('phoneNumber', value),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    leading: const Icon(Icons.logout, color: Colors.deepPurple),
                    title: const Text(
                      'Sign Out',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      BlocProvider.of<AuthCubit>(context)
                          .signout(context)
                          .whenComplete(() {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                          return const MainApp();
                        }));
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
