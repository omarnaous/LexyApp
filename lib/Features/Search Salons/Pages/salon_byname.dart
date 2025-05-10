import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Search Salons/Pages/salon_details.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class SalonDetailsPageByName extends StatelessWidget {
  final String salonName;
  const SalonDetailsPageByName({super.key, required this.salonName});

  Stream<QuerySnapshot> _salonStream() {
    return FirebaseFirestore.instance
        .collection('Salons')
        .where('name', isEqualTo: salonName)
        .limit(1)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _salonStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Salon not found')),
          );
        }
        final doc = snapshot.data!.docs.first;
        final salonId = doc.id;
        final salonData = doc.data() as Map<String, dynamic>;
        Salon salon = Salon.fromMap(salonData);
        return SalonDetailsPage(salonId: salonId, salon: salon);
      },
    );
  }
}
