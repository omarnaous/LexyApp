import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/custom_textfield.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();

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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account.')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {}
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
        backgroundColor: Colors.white,
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Email cannot be changed.'),
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
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      leading:
                          const Icon(Icons.logout, color: Colors.deepPurple),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.grey),
                      onTap: _signOut,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.grey),
                      onTap: _deleteAccount,
                    ),
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
