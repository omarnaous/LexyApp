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
  List<Map<String, dynamic>> teamMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedCategories();
    _fetchTeamMembers();
  }

  // Fetch categories and services from Firestore
  Future<void> _fetchSavedCategories() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        final List<dynamic> savedCategories = salonDoc['categories'] ?? [];
        final List<dynamic> savedServices = salonDoc['services'] ?? [];
        setState(() {
          selectedCategories = List<String>.from(savedCategories);
          selectedServices = List<Map<String, dynamic>>.from(savedServices);
        });
      }
    } catch (e) {
      _showSnackBar('Error', 'Failed to fetch categories: $e', true);
    }
  }

  // Fetch team members from Firestore
  Future<void> _fetchTeamMembers() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        final List<dynamic> fetchedTeamMembers = salonDoc['teamMembers'] ?? [];
        setState(() {
          teamMembers = fetchedTeamMembers
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
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
      _showSnackBar('Error', 'Failed to update categories: $e', true);
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
      builder: (context) => AlertDialog(
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

                // Add services for the selected category and associate all team members
                if (services.containsKey(category)) {
                  for (var service in services[category]!) {
                    // Add all team members to this service
                    service['teamMembers'] = teamMembers;
                    if (!selectedServices
                        .any((s) => s['title'] == service['title'])) {
                      selectedServices.add(service);
                    }
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

  // Show confirmation dialog when removing a category
  void _showRemoveWarning(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: Text('All services under $category will be removed. Proceed?'),
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
                selectedServices
                    .removeWhere((service) => service['category'] == category);
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
                    color: isSelected ? Colors.deepPurple : Colors.transparent,
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
                onTap: () => _toggleCategory(category),
              ),
            );
          },
        ),
      ),
    );
  }
}
