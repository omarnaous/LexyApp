import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Business%20Store/constants.dart';

class SalonCategoryPage extends StatefulWidget {
  const SalonCategoryPage({super.key, this.isAdmin, this.salonId});
  final bool? isAdmin;
  final String? salonId;

  @override
  State<SalonCategoryPage> createState() => _SalonCategoryPageState();
}

class _SalonCategoryPageState extends State<SalonCategoryPage> {
  List<String> selectedCategories = [];
  List<Map<String, dynamic>> selectedServices = [];
  List<Map<String, dynamic>> teamMembers = [];
  List<String> firestoreCategories = [];
  String? userId = '';

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin == true) {
      userId = widget.salonId;
    } else {
      userId = FirebaseAuth.instance.currentUser!.uid;
    }
    _fetchSavedCategories();
    _fetchTeamMembers();
    _fetchFirestoreCategories();
  }

  // Fetch additional categories from Firestore
  Future<void> _fetchFirestoreCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('SalonCategories').get();

      setState(() {
        firestoreCategories =
            querySnapshot.docs
                .map((doc) => doc['categoryName'] as String)
                .toList();
      });
    } catch (e) {
      _showSnackBar('Error', 'Failed to fetch categories: $e', true);
    }
  }

  // Fetch categories and services from Firestore
  Future<void> _fetchSavedCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        final List<dynamic> savedCategories = salonDoc['categories'] ?? [];
        final List<dynamic> savedServices = salonDoc['services'] ?? [];

        setState(() {
          selectedCategories = List<String>.from(savedCategories);
          print(selectedCategories);
          selectedServices = List<Map<String, dynamic>>.from(savedServices);

          // Automatically include Firestore categories if they are part of savedCategories
          for (String category in firestoreCategories) {
            if (selectedCategories.contains(category) &&
                !services.containsKey(category)) {
              services[category] = [];
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error', 'Failed to fetch saved categories: $e', true);
    }
  }

  // Fetch team members from Firestore
  Future<void> _fetchTeamMembers() async {
    if (userId == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        final List<dynamic> fetchedTeamMembers = salonDoc['teamMembers'] ?? [];
        setState(() {
          teamMembers =
              fetchedTeamMembers
                  .map((member) => member as Map<String, dynamic>)
                  .toList();
        });
      }
    } catch (e) {
      _showSnackBar('Error', 'Failed to fetch team members: $e', true);
    }
  }

  // Update categories and services in Firestore
  Future<void> _updateFirestore() async {
    if (userId == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'categories': selectedCategories,
          'services': selectedServices,
        });
      }
    } catch (e) {
      _showSnackBar('Error', 'Failed to update Firestore: $e', true);
    }
  }

  // Toggle selection of categories
  void _toggleCategory(String category) {
    final isSelected = selectedCategories.contains(category);

    if (isSelected) {
      _showRemoveWarning(category);
    } else {
      _showAddConfirmation(category);
    }
  }

  // Show confirmation dialog when adding a category
  void _showAddConfirmation(String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Addition'),
            content: Text('$category will be added with its services.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedCategories.add(category);

                    if (services.containsKey(category)) {
                      for (var service in services[category]!) {
                        service['teamMembers'] = teamMembers;
                        selectedServices.add(service);
                      }
                    }
                  });
                  _updateFirestore();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  // Show warning dialog when removing a category
  void _showRemoveWarning(String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Removal'),
            content: Text(
              'All services under $category will be removed. Proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedCategories.remove(category);
                    selectedServices.removeWhere(
                      (service) => service['category'] == category,
                    );
                  });
                  _updateFirestore();
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  // Show a custom SnackBar
  void _showSnackBar(String title, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = {...services.keys, ...firestoreCategories}.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Salon Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: allCategories.length,
          itemBuilder: (context, index) {
            final category = allCategories[index];
            final isSelected = selectedCategories.contains(category);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                title: Text(category),
                onTap: () => _toggleCategory(category),
              ),
            );
          },
        ),
      ),
    );
  }
}
