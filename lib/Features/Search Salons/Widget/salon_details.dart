import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_state.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/about_salon_text.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/google_map.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/image_carousel.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/rating_tile.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_basic_details.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/service_tile.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/services_list.dart';
import 'package:lexyapp/general_widget.dart';

class SalonDetailsPage extends StatefulWidget {
  final Salon salon;
  final String salonId;
  const SalonDetailsPage({
    super.key,
    required this.salon,
    required this.salonId,
  });

  @override
  State<SalonDetailsPage> createState() => _SalonDetailsPageState();
}

class _SalonDetailsPageState extends State<SalonDetailsPage> {
  final int _currentCarouselIndex = 0;

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((review) => review.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = widget.salon.imageUrls;

    int today = DateTime.now().weekday - 1;

    List<String> openingHours = [
      "10:00 AM - 10:00 PM", // Monday
      "10:00 AM - 10:00 PM", // Tuesday
      "10:00 AM - 10:00 PM", // Wednesday
      "10:00 AM - 10:00 PM", // Thursday
      "10:00 AM - 10:00 PM", // Friday
      "10:00 AM - 10:00 PM", // Saturday
      "10:00 AM - 10:00 PM" // Sunday
    ];

    String todayHours = openingHours[today];

    // Calculate the average rating for the salon
    double averageRating = _calculateAverageRating(widget.salon.reviews);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Salon Image Carousel
          SliverToBoxAdapter(
            child: SalonImagesCarousel(
              imageUrls: imageUrls,
              currentCarouselIndex: _currentCarouselIndex,
            ),
          ),
          SalonBasicDetails(widget: widget, todayHours: todayHours),
          AboutSalonText(widget: widget),
          RatingsTile(averageRating: averageRating, widget: widget),
          ServiceTile(widget: widget),
          ServicesList(widget: widget),
          SliverPadding(
            padding:
                const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LocationMap(
                  latitude: widget.salon.location.latitude,
                  longitude: widget.salon.location.longitude),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                // Add to Favourites Button
                Expanded(
                  child: BlocListener<FavouritesCubit, FavouritesState>(
                    listener: (context, state) {
                      if (state is FavouritesAdded) {
                        showCustomSnackBar(context, 'Added to Favourites',
                            '${widget.salon.name} Added to Favourites!');
                      }
                      if (state is FavouritesError) {
                        showCustomSnackBar(
                            context,
                            isError: true,
                            'Already Added to Favourites',
                            '${widget.salon.name} is already added to favourites!');
                      }
                    },
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<FavouritesCubit>().addSalonToFavourites(
                              widget.salonId,
                            );
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.deepPurple,
                        size: 25,
                      ),
                      label: Text(
                        'Add to favourites',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.white,
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

                // Book Now Button with Calendar Icon
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Book appointment action
                    },
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.deepPurple,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
