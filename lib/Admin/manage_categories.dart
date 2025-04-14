import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TextEditingController _categoryController = TextEditingController();
  List<String> firestoreCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchFirestoreCategories();
  }

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
      _showSnackBar('Error fetching categories: $e', true);
    }
  }

  Future<void> _addCategory() async {
    final categoryName = _categoryController.text.trim();
    if (categoryName.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('SalonCategories').add({
        'categoryName': categoryName,
      });

      setState(() {
        firestoreCategories.add(categoryName);
      });

      _categoryController.clear();
      _showSnackBar('Category added successfully!', false);
    } catch (e) {
      _showSnackBar('Error adding category: $e', true);
    }
  }

  Future<void> _removeCategory(String categoryName) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('SalonCategories')
              .where('categoryName', isEqualTo: categoryName)
              .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        firestoreCategories.remove(categoryName);
      });

      _showSnackBar('Category removed successfully!', false);
    } catch (e) {
      _showSnackBar('Error removing category: $e', true);
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'New Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _addCategory,
                      child: const Text(
                        'Add Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: firestoreCategories.length,
                itemBuilder: (context, index) {
                  final category = firestoreCategories[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Text(
                        category,
                        style: TextStyle(color: Colors.deepPurple.shade700),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCategory(category),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
