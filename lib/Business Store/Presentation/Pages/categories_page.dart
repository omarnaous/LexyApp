import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalonCategoryPage extends StatefulWidget {
  const SalonCategoryPage({super.key});

  @override
  State<SalonCategoryPage> createState() => _SalonCategoryPageState();
}

class _SalonCategoryPageState extends State<SalonCategoryPage> {
  final List<String> categories = [
    "Hair Salon",
    "Nail Salon",
    "Spa",
    "Barber Shop",
    "Beauty Salon",
    "Massage Center",
    "Makeup Studio",
    "Waxing Studio",
    "Skincare Clinic",
  ];

  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedCategories();
  }

  Future<void> _fetchSavedCategories() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        final List<dynamic> savedCategories = salonDoc['categories'] ?? [];
        setState(() {
          selectedCategories = List<String>.from(savedCategories);
        });
      } else {
        _showCustomSnackBar(
          'No Salon Found',
          'No salon found for the current user.',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        'Error Fetching Categories',
        'Failed to fetch categories: $e',
        isError: true,
      );
    }
  }

  void _saveCategories() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;

        await salonDoc.reference.update({
          'categories': selectedCategories,
        });

        _showCustomSnackBar(
          'Categories Saved',
          'Salon categories updated successfully!',
        );
      } else {
        _showCustomSnackBar(
          'No Salon Found',
          'No salon found for the current user.',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        'Error Saving Categories',
        'Failed to save categories: $e',
        isError: true,
      );
    }
  }

  void _showCustomSnackBar(String title, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salon Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategories.contains(category);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedCategories.remove(category);
                          } else {
                            selectedCategories.add(category);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveCategories,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
