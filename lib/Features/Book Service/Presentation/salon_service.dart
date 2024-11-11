// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/booking_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({
    super.key,
    required this.servicesList,
    required this.teamMembers,
    required this.salonId,
  });

  final List<ServiceModel> servicesList;
  final List<Team> teamMembers;
  final String salonId;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<ServiceModel> _selectedServices = [];

  void _toggleServiceSelection(ServiceModel service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
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
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (_selectedServices.contains(service)) {
                          return Colors.deepPurple; // Checked state color
                        }
                        return Colors.deepPurple[
                            100]!; // Unchecked state color (light purple)
                      },
                    ),
                    onChanged: (value) {
                      _toggleServiceSelection(service);
                    },
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
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
                              ],
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
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return BookingPage(
                      services: _selectedServices,
                      salonId: widget.salonId,
                      teamMembers: widget.teamMembers,
                    );
                  }));
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
