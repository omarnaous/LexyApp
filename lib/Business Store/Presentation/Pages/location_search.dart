import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Business%20Store/Data/location_model.dart';
import 'package:lexyapp/Business%20Store/Logic/location_helper.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/custom_textfield.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController searchController = TextEditingController();
  Future<List<GoogleLocationModel>>? searchResultsFuture;
  GoogleLocationModel? selectedLocation;

  void _searchLocations(String query) {
    if (query.isEmpty) {
      return;
    }
    setState(() {
      searchResultsFuture = LocationHelperClass().search(query);
    });
  }

  Future<void> _saveSelectedLocation() async {
    if (selectedLocation == null) {
      showCustomSnackBar(
        context,
        'No Location Selected',
        'Please select a location first',
        isError: true,
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showCustomSnackBar(
        context,
        'User Not Logged In',
        'No user is currently logged in.',
        isError: true,
      );
      return;
    }

    try {
      // Update location and city in Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'location': GeoPoint(
            selectedLocation!.latitude,
            selectedLocation!.longitude,
          ),
          'city': selectedLocation!.address, // Add city information
        });

        showCustomSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Location Saved',
          'Location and city saved successfully!',
        );
      } else {
        showCustomSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'No Salon Found',
          'No salon found for the current user.',
          isError: true,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Error Saving Location',
        'Failed to save location: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Locations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: searchController,
              labelText: 'Search for locations',
              onSubmitted: (query) => _searchLocations(query),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<GoogleLocationModel>>(
              future: searchResultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No results found'));
                }

                final results = snapshot.data!;
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final location = results[index];

                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          RadioListTile<GoogleLocationModel>(
                            value: location,
                            groupValue: selectedLocation,
                            onChanged: (value) {
                              setState(() {
                                selectedLocation = value;
                              });
                            },
                            title: Text(location.name),
                            subtitle: Text(location.address),
                          ),
                          SizedBox(
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  location.latitude,
                                  location.longitude,
                                ),
                                zoom: 14.0,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(location.name),
                                  position: LatLng(
                                    location.latitude,
                                    location.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: location.name,
                                    snippet: location.address,
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSelectedLocation,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
