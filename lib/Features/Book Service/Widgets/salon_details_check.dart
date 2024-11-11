import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/ratings_widget.dart';
import 'package:lexyapp/custom_image.dart';

class SalonDetailsCheckOutCard extends StatelessWidget {
  final String salonId;

  const SalonDetailsCheckOutCard({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    DocumentReference salonRef =
        FirebaseFirestore.instance.collection('Salons').doc(salonId);

    return StreamBuilder<DocumentSnapshot>(
      stream: salonRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          return const Center(child: Text('Salon does not exist'));
        }

        Map<String, dynamic> data =
            snapshot.data!.data()! as Map<String, dynamic>;
        Salon salon = Salon.fromMap(data);
        double averageRating = salon.reviews.isEmpty
            ? 0.0
            : salon.reviews
                    .map((review) => review.rating)
                    .reduce((a, b) => a + b) /
                salon.reviews.length;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CustomImage(
                  imageUrl:
                      salon.imageUrls.isNotEmpty ? salon.imageUrls[0] : '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    RatingsWidget(
                        rating: averageRating,
                        totalRatings: salon.reviews.length),
                    const SizedBox(height: 5),
                    Text(
                      salon.city,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
