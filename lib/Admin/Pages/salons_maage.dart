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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalonList(true), // Active salons
          _buildSalonList(false), // Inactive salons
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
          return data['active'] == isActive;
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
                      return AdminSalonEdit(salonId: salon.ownerUid);
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
                    trailing: Switch(
                      value: salon.active,
                      onChanged: (newValue) {
                        _updateSalonStatus(salonId, newValue);
                      },
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
}
