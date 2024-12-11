// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/booking_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/general_widget.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({
    Key? key,
    required this.servicesList,
    required this.teamMembers,
    required this.salonId,
    required this.salon,
  }) : super(key: key);

  final List<ServiceModel> servicesList;
  final List<Team> teamMembers;
  final String salonId;
  final Salon salon;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<ServiceModel> _selectedServices = [];
  final Map<ServiceModel, Team> _selectedTeamForService = {};

  @override
  void initState() {
    super.initState();
    // Ensure "Anyone" is added as the first option
    if (!widget.teamMembers.any((member) => member.name == "Anyone")) {
      widget.teamMembers.insert(0, Team(name: "Anyone", imageLink: ""));
    }
  }

  void _toggleServiceSelection(ServiceModel service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
        _selectedTeamForService.remove(service);
      } else {
        _selectedServices.add(service);
        _selectedTeamForService[service] = widget.teamMembers.first;
      }
    });
  }

  void _setTeamMemberForService(ServiceModel service, Team team) {
    setState(() {
      _selectedTeamForService[service] = team;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salon Services"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.servicesList.length,
        itemBuilder: (context, index) {
          final service = widget.servicesList[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.5, // Increase the size of the checkbox
                  child: Checkbox(
                    shape: const CircleBorder(),
                    value: _selectedServices.contains(service),
                    activeColor: Colors.deepPurple,
                    checkColor: Colors.white,
                    onChanged: (value) {
                      _toggleServiceSelection(service);
                    },
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 3, // Added elevation for a modern look
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            service.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'USD ${service.price} - Book Now',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 5),
                          if (_selectedServices.contains(service))
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: DropdownButtonFormField<Team>(
                                value: _selectedTeamForService[service],
                                isExpanded: true, // Ensures full width
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.deepPurple.shade100,
                                  labelText: 'Select Team Member',
                                  labelStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                elevation: 6, // Elevation for dropdown menu
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: widget.teamMembers.map((member) {
                                  return DropdownMenuItem<Team>(
                                    value: member,
                                    child: Text(member.name),
                                  );
                                }).toList(),
                                onChanged: (team) {
                                  if (team != null) {
                                    _setTeamMemberForService(service, team);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _selectedServices.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    showCustomModalBottomSheet(context, const SignUpPage(), () {
                      Navigator.of(context).pop();
                    });
                  } else {
                    final List<Map<String, dynamic>> servicesWithTeamMembers =
                        _selectedServices.map((service) {
                      final selectedTeamMember =
                          _selectedTeamForService[service];
                      return {
                        'service': service, // Include the full ServiceModel
                        'teamMember': selectedTeamMember ??
                            Team(
                                name: 'Anyone',
                                imageLink: ''), // Include the full Team object
                      };
                    }).toList();

                    print(servicesWithTeamMembers);

                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return BookingPage(
                        salonModel: widget.salon,
                        services:
                            servicesWithTeamMembers, // Pass the list of maps
                        salonId: widget.salonId,
                        teamMembers: widget.teamMembers,
                      );
                    }));
                  }
                },
                child: const Text(
                  "Book Selected Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
