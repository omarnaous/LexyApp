// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key, this.isAdmin, this.owneruid});
  final bool? isAdmin;
  final String? owneruid;

  static const String googleApiKey = 'AIzaSyDLQuFQJ3NywrYLHlKTmSNIlTrHmIBnOgo';

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  PickResult? selectedPlace;

  Future<void> _saveLocation(BuildContext context) async {
    if (selectedPlace == null) {
      showCustomSnackBar(context, 'Error', 'No location selected.');
      return;
    }

    final userId =
        widget.isAdmin == true
            ? widget.owneruid
            : FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showCustomSnackBar(context, 'Error', 'No user is currently logged in.');
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
          'location': GeoPoint(
            selectedPlace!.geometry?.location.lat ?? 0.0,
            selectedPlace!.geometry?.location.lng ?? 0.0,
          ),
          'city': selectedPlace!.formattedAddress ?? 'Unknown Location',
        });

        print(selectedPlace!.formattedAddress);

        showCustomSnackBar(context, 'Success', 'Location saved successfully!');
      } else {
        showCustomSnackBar(
          context,
          'Error',
          'No salon found for the current user.',
        );
      }
    } catch (e) {
      showCustomSnackBar(context, 'Error', 'Error saving location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Pin on Map')),
      body: PlacePicker(
        apiKey: 'AIzaSyDLQuFQJ3NywrYLHlKTmSNIlTrHmIBnOgo',
        hintText: 'Search...',
        initialPosition: const LatLng(33.8938, 35.5018),
        selectInitialPosition: true,
        autocompleteLanguage: 'en',
        forceSearchOnZoomChanged: false,
        automaticallyImplyAppBarLeading: false,
        enableMapTypeButton: true,
        enableMyLocationButton: true,
        selectText: 'Select this location',
        selectedPlaceWidgetBuilder: (
          context,
          selectedPlace2,
          state,
          isSearchBarFocused,
        ) {
          return selectedPlace2 == null
              ? Container()
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Display selected place name
                          Text(
                            selectedPlace2.name ?? 'No name available',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Display the selected address
                          Text(
                            selectedPlace2.formattedAddress ??
                                'No address available',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Save button
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedPlace = selectedPlace2;
                              });

                              _saveLocation(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple, // Set the background color
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 40,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Save Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
        },
        onCameraMove: (position) {},
      ),
    );
  }
}
