import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lexyapp/Business%20Store/constants.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key, this.isAdmin, this.salonId});
  final bool? isAdmin;
  final String? salonId;

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> teamMembers = [];
  String? userId = '';
  // List to store the selected category for the picker.
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    // For admin, use the provided salonId, otherwise use the current Firebase user.
    if (widget.isAdmin == true) {
      userId = widget.salonId;
    } else {
      userId = FirebaseAuth.instance.currentUser?.uid;
    }
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }
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
      } else {
        _showCustomSnackBar(
          'No Salon Found',
          'No salon found for the current user.',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        'Error Fetching Team Members',
        'Failed to fetch team members: $e',
        isError: true,
      );
    }
  }

  Future<void> _addTeamMember() async {
    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      _showCustomSnackBar(
        'Incomplete Details',
        'Please fill in both the name and description.',
        isError: true,
      );
      return;
    }
    final newMember = {
      'name': nameController.text,
      'description': descriptionController.text,
    };
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'teamMembers': FieldValue.arrayUnion([newMember]),
        });
        setState(() {
          teamMembers.add(newMember);
        });
        nameController.clear();
        descriptionController.clear();
        _showCustomSnackBar(
          'Team Member Added',
          'The team member has been added successfully!',
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
        'Error Adding Team Member',
        'Failed to add team member: $e',
        isError: true,
      );
    }
  }

  Future<void> _deleteTeamMember(Map<String, dynamic> member) async {
    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'teamMembers': FieldValue.arrayRemove([member]),
        });
        setState(() {
          teamMembers.remove(member);
        });
        _showCustomSnackBar(
          'Team Member Removed',
          'The team member has been removed successfully!',
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
        'Error Removing Team Member',
        'Failed to remove team member: $e',
        isError: true,
      );
    }
  }

  Future<void> _addTeamMemberToServices(int memberIndex) async {
    if (userId == null) {
      _showCustomSnackBar(
        'User Not Logged In',
        'No user is logged in.',
        isError: true,
      );
      return;
    }
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();
      if (querySnapshot.docs.isEmpty) {
        _showCustomSnackBar(
          'No Salon Found',
          'No salon found for the current user.',
          isError: true,
        );
        return;
      }
      final salonDoc = querySnapshot.docs.first;
      Map<String, dynamic> salonData = salonDoc.data();
      List services = salonData["services"] ?? [];
      // Get unique categories from services.
      Set<String> uniqueCategories =
          services.map((service) => service["category"] as String).toSet();
      // Clear previously selected categories.
      _selectedCategories = [];
      // Show the picker with an onChanged callback.
      showMaterialCheckboxPicker(
        context: context,
        title: 'Select a Category',
        items: uniqueCategories.toList(),
        selectedItems: _selectedCategories,
        onChanged: (List<String> val) {
          setState(() {
            _selectedCategories = val;
            print("onChanged: Selected categories: $_selectedCategories");
          });
        },
        onConfirmed: () {
          print("Picker confirmed callback triggered");
          print("Selected categories: $_selectedCategories");
          if (_selectedCategories.isNotEmpty) {
            String chosenCategory = _selectedCategories.first;
            _handleUpdateServices(
              salonDoc.id,
              services,
              memberIndex,
              chosenCategory,
            );
          } else {
            print("No category selected");
          }
        },
      );
    } catch (e) {
      _showCustomSnackBar(
        'Error',
        'Failed to fetch salon data: $e',
        isError: true,
      );
    }
  }

  // This helper function performs the Firestore update asynchronously.
  Future<void> _handleUpdateServices(
    String salonDocId,
    List services,
    int memberIndex,
    String chosenCategory,
  ) async {
    // Create your new team member object using your Team model.
    var newTeamMember = Team.fromMap(teamMembers[memberIndex]).toMap();
    // Update only services that match the chosen category.
    services.forEach((service) {
      if (service["category"] == chosenCategory) {
        if (service['teamMembers'] != null) {
          service['teamMembers'].add(newTeamMember);
        } else {
          service['teamMembers'] = [newTeamMember];
        }
      }
    });
    try {
      await FirebaseFirestore.instance
          .collection('Salons')
          .doc(salonDocId)
          .update({'services': services});
      _showCustomSnackBar(
        'Success',
        'Team member added for category: $chosenCategory',
      );
    } catch (e) {
      _showCustomSnackBar(
        'Error',
        'Failed to update services: $e',
        isError: true,
      );
    }
  }

  void _showCustomSnackBar(
    String title,
    String message, {
    bool isError = false,
  }) {
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
            Text(message, style: const TextStyle(color: Colors.white)),
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
          'Team Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Team Member',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: nameController,
              labelText: 'Team Member Name',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: descriptionController,
              labelText: 'Team Member Description',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTeamMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(member['description'] ?? ''),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () => _deleteTeamMember(member),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _addTeamMemberToServices(index);
                            },
                            child: const Text(
                              "Add to All Services",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
