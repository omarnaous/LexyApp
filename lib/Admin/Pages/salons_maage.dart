import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Admin/Pages/salon_edit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class SalonManagement extends StatefulWidget {
  const SalonManagement({super.key});

  @override
  State<SalonManagement> createState() => _SalonManagementState();
}

class _SalonManagementState extends State<SalonManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salons'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Salon Name . . .',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalonList(true), // Active salons
                _buildSalonList(false), // Inactive salons
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalonList(bool isActive) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Salons').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No salons available.'));
        }

        var salons = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          // Filter by active status
          if (data['active'] != isActive) return false;

          // Filter by search query
          final name = data['name']?.toString().toLowerCase() ?? '';
          final city = data['city']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery) || city.contains(_searchQuery);
        }).toList();

        if (salons.isEmpty) {
          return Center(
            child: Text(isActive ? 'No active salons' : 'No inactive salons'),
          );
        }

        return ListView.builder(
          itemCount: salons.length,
          itemBuilder: (context, index) {
            var salonDoc = salons[index];
            var salonData = salonDoc.data() as Map<String, dynamic>;
            var salon = Salon.fromMap(salonData);
            String salonId = salonDoc.id; // Get document ID from Firestore

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return AdminSalonEdit(ownerUId: salon.ownerUid);
                    },
                  ));
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: salon.imageUrls.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(salon.imageUrls[0]),
                          )
                        : const Icon(Icons.store, size: 40),
                    title: Text(salon.name),
                    subtitle: Text(salon.city),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Switch for active/inactive status
                        Switch(
                          value: salon.active,
                          onChanged: (newValue) {
                            _updateSalonStatus(salonId, newValue);
                          },
                        ),
                        // Delete button for inactive salons
                        if (!isActive)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(salonId);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateSalonStatus(String salonId, bool isActive) {
    FirebaseFirestore.instance.collection('Salons').doc(salonId).update({
      'active': isActive,
    });
  }

  void _showDeleteConfirmationDialog(String salonId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Salon'),
          content: const Text('Are you sure you want to delete this salon?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSalon(salonId); // Delete the salon
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSalon(String salonId) {
    FirebaseFirestore.instance
        .collection('Salons')
        .doc(salonId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salon deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete salon: $error')),
      );
    });
  }
}
