import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';

class EditServicePage extends StatefulWidget {
  const EditServicePage({
    super.key,
    required this.salonModel,
    this.serviceModel,
    this.index,
    required this.isEditing,
  });
  final Salon salonModel;
  final ServiceModel? serviceModel; // Optional for adding new service
  final int? index; // Optional for adding new service
  final bool isEditing; // Determines if the page is in edit or add mode

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();
  final TextEditingController _serviceDurationController =
      TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  List<Team> _selectedTeamMembers = [];

  @override
  void initState() {
    super.initState();

    // Prefill fields if in edit mode
    if (widget.isEditing && widget.serviceModel != null) {
      _serviceNameController.text = widget.serviceModel!.title;
      _serviceDescriptionController.text = widget.serviceModel!.description;
      _serviceDurationController.text =
          widget.serviceModel!.duration.toString();
      _servicePriceController.text = widget.serviceModel!.price.toString();
      _categoryController.text = widget.serviceModel!.category;
      _selectedTeamMembers = widget.serviceModel!.teamMembers ?? [];
    }
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch the specific salon document
        var salonQuery = await FirebaseFirestore.instance
            .collection("Salons")
            .where('ownerUid', isEqualTo: widget.salonModel.ownerUid)
            .get();

        if (salonQuery.docs.isNotEmpty) {
          var salonDoc = salonQuery.docs.first;
          List<dynamic> services = salonDoc["services"] ?? [];

          // Create the new/updated service
          final newService = {
            "title": _serviceNameController.text,
            "description": _serviceDescriptionController.text,
            "duration": int.tryParse(_serviceDurationController.text) ?? 0,
            "price": double.tryParse(_servicePriceController.text) ?? 0.0,
            "category": _categoryController.text,
            "teamMembers": _selectedTeamMembers
                .map((teamMember) => teamMember.toMap())
                .toList(),
          };

          if (widget.isEditing && widget.index != null) {
            // Update the existing service
            services[widget.index!] = newService;
          } else {
            // Add the new service
            services.add(newService);
          }

          // Save the updated services back to Firestore
          await FirebaseFirestore.instance
              .collection("Salons")
              .doc(salonDoc.id)
              .update({"services": services});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? "Service updated successfully!"
                  : "Service added successfully!"),
            ),
          );
          Navigator.pop(context); // Go back after successful save
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Salon not found!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save service: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Service" : "Add Service"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: _saveService,
        label: Text(
          widget.isEditing ? "Save Changes" : "Add Service",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomTextField(
                  controller: _serviceNameController,
                  labelText: 'Service Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomTextField(
                  controller: _serviceDescriptionController,
                  labelText: 'Service Description',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomTextField(
                  controller: _serviceDurationController,
                  labelText: 'Service Duration (Mins)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomTextField(
                  controller: _servicePriceController,
                  labelText: 'Service Price (USD)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomTextField(
                  controller: _categoryController,
                  labelText: 'Service Category',
                  readOnly: true,
                  onTap: () {
                    showMaterialRadioPicker(
                        context: context,
                        items: widget.salonModel.categories!.toList(),
                        onChanged: (newValue) {
                          _categoryController.text = newValue;
                        });
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            // Team member selection (same as before)
            SliverToBoxAdapter(
              child: ElevatedButton(
                onPressed: () {
                  showMaterialCheckboxPicker(
                    context: context,
                    items: widget.salonModel.team
                        .map((teamMember) => teamMember.name)
                        .toList(),
                    selectedItems: _selectedTeamMembers
                        .map((teamMember) => teamMember.name)
                        .toList(),
                    onChanged: (List<String> selected) {
                      setState(() {
                        _selectedTeamMembers = widget.salonModel.team
                            .where((teamMember) =>
                                selected.contains(teamMember.name))
                            .toList();
                      });
                    },
                  );
                },
                child: const Text("Add Team Members"),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selected Team Members",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    ..._selectedTeamMembers.map((teamMember) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Chip(
                          label: Text(teamMember.name),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              _selectedTeamMembers.remove(teamMember);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
