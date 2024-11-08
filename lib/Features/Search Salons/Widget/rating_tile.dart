import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/ratings_widget.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_details.dart';

class RatingsTile extends StatelessWidget {
  const RatingsTile({
    super.key,
    required this.averageRating,
    required this.widget,
  });

  final double averageRating;
  final SalonDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        title: Text(
          "Reviews",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
        ),
        subtitle: RatingsWidget(
            rating: averageRating, totalRatings: widget.salon.reviews.length),
        trailing: TextButton(
          onPressed: () {},
          child: Text(
            "View All",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.deepPurple, // You can change the color
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        ),
      ),
    );
  }
}
