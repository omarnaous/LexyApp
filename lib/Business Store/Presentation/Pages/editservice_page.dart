import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';

class EditServicePage extends StatefulWidget {
  const EditServicePage({
    super.key,
    required this.serviceModel,
    required this.index,
    required this.salonModel,
  });
  final ServiceModel serviceModel;
  final int index;
  final Salon salonModel;

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController servicedescriptionControlloer = TextEditingController();
  TextEditingController serviceDurationControlloer = TextEditingController();
  TextEditingController servicePriceControlloer = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController teamController = TextEditingController();

  List<Team> selectedTeamMembers = [];

  @override
  void initState() {
    serviceNameController.text = widget.serviceModel.title;
    servicedescriptionControlloer.text = widget.serviceModel.description;
    serviceDurationControlloer.text = widget.serviceModel.duration.toString();
    servicePriceControlloer.text = widget.serviceModel.price.toString();
    categoryController.text = widget.serviceModel.category;
    selectedTeamMembers = widget.serviceModel.teamMembers ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Services"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          try {
            // Fetch the specific salon document
            var salonQuery = await FirebaseFirestore.instance
                .collection("Salons")
                .where('ownerUid', isEqualTo: widget.salonModel.ownerUid)
                .get();

            if (salonQuery.docs.isNotEmpty) {
              // Get the first document of the query result
              var salonDoc = salonQuery.docs.first;

              // Retrieve the current list of services
              List<dynamic> services = salonDoc["services"] ?? [];

              // Validate the index is within bounds of the services list
              if (widget.index >= 0 && widget.index < services.length) {
                // Update the specific service at the given index
                services[widget.index] = {
                  "title": serviceNameController.text,
                  "description": servicedescriptionControlloer.text,
                  "duration":
                      int.tryParse(serviceDurationControlloer.text) ?? 0,
                  "price": double.tryParse(servicePriceControlloer.text) ?? 0.0,
                  "category": categoryController.text,
                  "teamMembers": selectedTeamMembers
                      .map((teamMember) => teamMember.toMap())
                      .toList(),
                };

                // Save the updated services back to Firestore
                await FirebaseFirestore.instance
                    .collection("Salons")
                    .doc(salonDoc.id)
                    .update({"services": services});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Service updated successfully!")),
                );
                Navigator.pop(context); // Go back after successful update
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid service index!")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Salon not found!")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update service: $e")),
            );
          }
        },
        label: const Text(
          "Save Service",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                controller: serviceNameController,
                labelText: 'Service title',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                controller: servicedescriptionControlloer,
                labelText: 'Service Description',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                controller: serviceDurationControlloer,
                labelText: 'Service Duration (Mins)',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                controller: servicePriceControlloer,
                labelText: 'Service Price (USD)',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                controller: categoryController,
                labelText: 'Service Category',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Add Team Members",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          // Rest of the code remains unchanged
        ],
      ),
    );
  }
}
