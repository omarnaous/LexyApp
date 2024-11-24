import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_card.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({
    super.key,
    required this.data,
  });
  final List<String> data;

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  Stream<List<Map<String, dynamic>>> _streamFavouriteSalons(
      List<String>? favouriteIds) async* {
    if (favouriteIds == null || favouriteIds.isEmpty) {
      yield [];
      return;
    }

    try {
      final salonSnapshots = await Future.wait(
        favouriteIds.map(
          (id) => FirebaseFirestore.instance.collection('Salons').doc(id).get(),
        ),
      );

      final salons =
          salonSnapshots.where((snapshot) => snapshot.exists).map((snapshot) {
        final data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id; // Add the document ID
        return data;
      }).toList();

      yield salons;
    } catch (e) {
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Favourites'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamFavouriteSalons(widget.data),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Favourites Found!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final favouriteSalons = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: favouriteSalons.length,
              itemBuilder: (context, index) {
                final salonData = favouriteSalons[index];
                final salon = Salon.fromMap(salonData);
                final salonId = salonData['id'];

                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SalonCard(
                    salon: salon,
                    salonId: salonId,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
