// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/reviews_details.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/ratings_widget.dart';

class RatingsTile extends StatelessWidget {
  const RatingsTile({
    super.key,
    required this.averageRating,
    required this.salon,
    required this.docID,
  });

  final double averageRating;
  final Salon salon;
  final String docID;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Reviews",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
      ),
      subtitle: RatingsWidget(
          rating: averageRating, totalRatings: salon.reviews.length),
      trailing: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return SalonReviewsPage(
                  salon: salon,
                  salonId: docID,
                );
              },
            ),
          );
        },
        child: Text(
          "View All",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.deepPurple, // You can change the color
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}
