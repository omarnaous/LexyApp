import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Business%20Store/constants.dart';

class SalonCategoryPage extends StatefulWidget {
  const SalonCategoryPage({super.key});

  @override
  State<SalonCategoryPage> createState() => _SalonCategoryPageState();
}

class _SalonCategoryPageState extends State<SalonCategoryPage> {
  List<String> selectedCategories = [];
  List<Map<String, dynamic>> selectedServices = [];

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

        // Update the Firestore document to match the current selections
        await salonDoc.reference.update({
          'categories': selectedCategories,
          'services': selectedServices,
        });

        // Optional: Provide user feedback
        _showCustomSnackBar(
          'Categories Updated',
          'Your selections have been successfully saved.',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final category = services.keys.elementAt(index);
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
                            if (services.containsKey(category)) {
                              selectedServices.removeWhere((service) =>
                                  services[category]!.any(
                                      (s) => s['title'] == service['title']));
                            }
                          } else {
                            selectedCategories.add(category);
                            if (services.containsKey(category)) {
                              for (var service in services[category]!) {
                                if (!selectedServices.any(
                                    (s) => s['title'] == service['title'])) {
                                  selectedServices.add(service);
                                }
                              }
                            }
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
