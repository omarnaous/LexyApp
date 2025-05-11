import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.25,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ), // Adjust the radius as needed
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('location_marker'),
              position: LatLng(latitude, longitude),
            ),
          },
          myLocationButtonEnabled: false, // Disable the floating button
          zoomControlsEnabled: false, // Optional: Remove zoom controls as well
        ),
      ),
    );
  }
}
