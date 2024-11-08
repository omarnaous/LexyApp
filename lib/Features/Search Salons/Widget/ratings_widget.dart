import 'package:flutter/material.dart';

class RatingsWidget extends StatelessWidget {
  final double rating; // Rating between 1 to 5
  final int totalRatings; // Total number of ratings

  const RatingsWidget({
    super.key,
    required this.rating,
    required this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, color: Colors.deepPurple, size: 16);
            } else if (index < rating) {
              return const Icon(Icons.star_half,
                  color: Colors.deepPurple, size: 16);
            } else {
              return const Icon(Icons.star_border,
                  color: Colors.deepPurple, size: 16);
            }
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '($totalRatings)',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
