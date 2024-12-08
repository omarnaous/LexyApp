import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lexyapp/Business%20Store/Data/location_model.dart';
import 'package:lexyapp/Business%20Store/Logic/location_helper.dart';

class LocationSearchPage extends StatefulWidget {
  final Function(GoogleLocationModel) onLocationSelected;

  const LocationSearchPage({super.key, required this.onLocationSelected});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController searchController = TextEditingController();
  Future<List<GoogleLocationModel>>? searchResultsFuture;

  void _searchLocations(String query) {
    if (query.isEmpty) {
      return;
    }
    setState(() {
      searchResultsFuture = LocationHelperClass().search(query);
    });
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
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search for locations',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _searchLocations(searchController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
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
                          ListTile(
                            title: Text(location.name),
                            subtitle: Text(location.address),
                            trailing: ElevatedButton(
                              onPressed: () {
                                widget.onLocationSelected(location);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                'Select',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    );
  }
}
