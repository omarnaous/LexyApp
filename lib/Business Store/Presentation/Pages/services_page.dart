import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:intl/intl.dart'; // For formatting currency

class AddServicesPage extends StatefulWidget {
  const AddServicesPage({super.key});

  @override
  State<AddServicesPage> createState() => _AddServicesPageState();
}

class _AddServicesPageState extends State<AddServicesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
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
        final fetchedServices =
            List<Map<String, dynamic>>.from(salonDoc['services'] ?? []);
        setState(() {
          services = fetchedServices;
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
        'Error Fetching Services',
        'Failed to fetch services: $e',
        isError: true,
      );
    }
  }

  Future<void> _addService() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }

    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        durationController.text.isEmpty) {
      _showCustomSnackBar(
        'Incomplete Details',
        'Please fill in all fields.',
        isError: true,
      );
      return;
    }

    final newService = {
      'title': titleController.text,
      'description': descriptionController.text,
      'price': int.tryParse(priceController.text.replaceAll('\$', '')) ?? 0,
      'duration': int.tryParse(durationController.text) ?? 0,
    };

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;

        await salonDoc.reference.update({
          'services': FieldValue.arrayUnion([newService]),
        });

        setState(() {
          services.add(newService);
        });

        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        durationController.clear();

        _showCustomSnackBar(
          'Service Added',
          'The service has been added successfully!',
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
        'Error Adding Service',
        'Failed to add service: $e',
        isError: true,
      );
    }
  }

  Future<void> _editService(Map<String, dynamic> service) async {
    titleController.text = service['title'];
    descriptionController.text = service['description'];
    priceController.text = service['price'].toString();
    durationController.text = service['duration'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: titleController,
              labelText: 'Service Name',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: descriptionController,
              labelText: 'Service Description',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: priceController,
              labelText: 'Service Price (\$)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: durationController,
              labelText: 'Duration (mins)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              final updatedService = {
                'title': titleController.text,
                'description': descriptionController.text,
                'price': int.tryParse(priceController.text) ?? 0,
                'duration': int.tryParse(durationController.text) ?? 0,
              };

              try {
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('Salons')
                    .where('ownerUid', isEqualTo: userId)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  final salonDoc = querySnapshot.docs.first;

                  await salonDoc.reference.update({
                    'services': FieldValue.arrayRemove([service]),
                  });

                  await salonDoc.reference.update({
                    'services': FieldValue.arrayUnion([updatedService]),
                  });

                  setState(() {
                    services.remove(service);
                    services.add(updatedService);
                  });

                  Navigator.pop(context);
                  _showCustomSnackBar(
                    'Service Updated',
                    'The service has been updated successfully!',
                  );
                }
              } catch (e) {
                _showCustomSnackBar(
                  'Error Updating Service',
                  'Failed to update service: $e',
                  isError: true,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(Map<String, dynamic> service) async {
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
          'services': FieldValue.arrayRemove([service]),
        });

        setState(() {
          services.remove(service);
        });

        _showCustomSnackBar(
          'Service Deleted',
          'The service has been deleted successfully!',
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
        'Error Deleting Service',
        'Failed to delete service: $e',
        isError: true,
      );
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(price);
  }

  void _showCustomSnackBar(String title, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.deepPurple,
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
          'Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Service',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: titleController,
              labelText: 'Service Name',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: descriptionController,
              labelText: 'Service Description',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: priceController,
              labelText: 'Service Price (\$)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: durationController,
              labelText: 'Duration (mins)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addService,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Services',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        service['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${service['description'] ?? ''}\nPrice: ${_formatPrice(service['price'] ?? 0)}\nDuration: ${service['duration'] ?? 0} mins',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.deepPurple),
                            onPressed: () => _editService(service),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.deepPurple),
                            onPressed: () => _deleteService(service),
                          ),
                        ],
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
