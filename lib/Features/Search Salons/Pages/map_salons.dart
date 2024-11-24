import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';

class SalonMapPage extends StatefulWidget {
  const SalonMapPage({super.key});

  @override
  State<SalonMapPage> createState() => _SalonMapPageState();
}

class _SalonMapPageState extends State<SalonMapPage> {
  final Set<Marker> _markers = {};
  final LatLng _initialPosition = const LatLng(33.8938, 35.5018);

  @override
  void initState() {
    super.initState();
    _loadSalonsNearby();
  }

  // Load salons and create markers
  Future<void> _loadSalonsNearby() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Salons').get();

    final salons = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the data map
      return Salon.fromMap(
          data); // Create the Salon object from the modified map
    }).toList();

    setState(() {
      _markers.clear();
      for (var salon in salons) {
        final LatLng position =
            LatLng(salon.location.latitude, salon.location.longitude);

        // Add marker for the salon
        final Marker marker = Marker(
          markerId: MarkerId(salon.name), // You can also use `salon.id`
          position: position,
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SalonDetailsPage(
                  salon: salon,
                  salonId: salon.name, // Replace with `salon.id` if needed
                ),
              ),
            );
          },
        );

        _markers.add(marker);
      }
    });
  }

  // Get the user's current location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition, // Initial map position
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {},
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      context.read<NavBarCubit>().showNavBar();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
