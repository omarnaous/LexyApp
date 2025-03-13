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
    required this.salonId,
    required this.salon,
    required this.teamMembers,
  }) : super(key: key);

  final List<ServiceModel> servicesList;
  final String salonId;
  final Salon salon;
  final List<Team> teamMembers;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<ServiceModel> _selectedServices = [];
  final Map<ServiceModel, Team> _selectedTeamForService = {};

  // Group services by category
  Map<String, List<ServiceModel>> _groupServicesByCategory() {
    final Map<String, List<ServiceModel>> groupedServices = {};
    for (var service in widget.servicesList) {
      final category = service.category ?? 'Uncategorized';
      if (!groupedServices.containsKey(category)) {
        groupedServices[category] = [];
      }
      groupedServices[category]!.add(service);
    }
    return groupedServices;
  }

  @override
  void initState() {
    super.initState();
  }

  void _toggleServiceSelection(ServiceModel service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
        _selectedTeamForService.remove(service);
      } else {
        _selectedServices.add(service);
        // Assign the first available team member or "Anyone" by default
        final initialTeamMember = service.teamMembers?.isNotEmpty == true
            ? service.teamMembers!.first
            : Team(name: "Anyone", imageLink: "");
        _selectedTeamForService[service] = initialTeamMember;
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
    final groupedServices = _groupServicesByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salon Services"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: groupedServices.entries.map((entry) {
          final category = entry.key;
          final services = entry.value;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ExpansionTile(
              title: Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
              ),
              children: services.map((service) {
                final isSelected = _selectedServices.contains(service);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              shape: const CircleBorder(),
                              value: isSelected,
                              activeColor: Colors.deepPurple,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                _toggleServiceSelection(service);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${service.duration} minutes - \$${service.price}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        service.teamMembers != null &&
                                service.teamMembers!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(5),
                                child: DropdownButtonFormField<Team>(
                                  value: _selectedTeamForService[service],
                                  isExpanded: true,
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
                                  elevation: 6,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: service.teamMembers!.map((member) {
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
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Text(
                                  'This service does not have any assigned team members at this moment!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                      const Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
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
                        'service': service,
                        'teamMember': selectedTeamMember ??
                            Team(name: 'Anyone', imageLink: ''),
                      };
                    }).toList();

                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return BookingPage(
                        salonModel: widget.salon,
                        services: servicesWithTeamMembers,
                        salonId: widget.salonId,
                        teamMembers: [], // Team members are handled per service
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
