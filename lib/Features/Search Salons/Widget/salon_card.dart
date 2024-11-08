// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/ratings_widget.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_details.dart';
import 'package:lexyapp/custom_image.dart';

class SalonCard extends StatefulWidget {
  const SalonCard({
    super.key,
    required this.salon,
    required this.salonId,
  });

  final Salon salon;
  final String salonId;

  @override
  State<SalonCard> createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard> {
  int _currentCarouselIndex = 0;

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((review) => review.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = widget.salon.imageUrls;
    double averageRating = _calculateAverageRating(widget.salon.reviews);
    int totalRatings = widget.salon.reviews.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SalonDetailsPage(
                salon: widget.salon,
                salonId: widget.salonId,
              );
            },
          ),
        );
        context.read<NavBarCubit>().hideNavBar();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
              child: Stack(
                children: [
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
                    itemBuilder: (BuildContext context, int itemIndex,
                        int pageViewIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImage(
                          imageUrl: imageUrls[itemIndex],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(imageUrls.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentCarouselIndex == index ? 12 : 8,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salon.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 4),
                  RatingsWidget(
                    rating: averageRating,
                    totalRatings: totalRatings,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.salon.city,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
