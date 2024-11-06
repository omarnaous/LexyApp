import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_image.dart';

class SalonCard extends StatefulWidget {
  const SalonCard({
    super.key,
    required this.usersQuery,
  });

  final CollectionReference<Salon> usersQuery;

  @override
  State<SalonCard> createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard> {
  int _currentCarouselIndex = 0;

  // Helper method to calculate the average rating
  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((review) => review.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FirestoreListView<Salon>(
          query: widget.usersQuery,
          itemBuilder: (context, snapshot) {
            Salon salon = snapshot.data();
            List<String> imageUrls = salon.imageUrls;
            double averageRating = _calculateAverageRating(salon.reviews);
            int totalRatings = salon.reviews.length;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              // Carousel Slider
                              CarouselSlider.builder(
                                options: CarouselOptions(
                                  height: 220,
                                  autoPlay: false,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                ),
                                itemCount: imageUrls.length,
                                itemBuilder: (BuildContext context,
                                    int itemIndex, int pageViewIndex) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CustomImage(
                                      imageUrl: imageUrls[itemIndex],
                                    ),
                                  );
                                },
                              ),
                              // Carousel Indicator
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      List.generate(imageUrls.length, (index) {
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: _currentCarouselIndex == index
                                          ? 12
                                          : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentCarouselIndex == index
                                            ? Colors.deepPurple
                                            : Colors.grey,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Salon name
                        Text(
                          salon.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        // Rating and stars below salon name
                        Row(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Stars with half stars support
                            Row(
                              children: List.generate(5, (index) {
                                if (index < averageRating.floor()) {
                                  return const Icon(Icons.star,
                                      color: Colors.deepPurple, size: 16);
                                } else if (index < averageRating) {
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
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // City under ratings
                        Text(salon.city, // Displaying the city here
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
