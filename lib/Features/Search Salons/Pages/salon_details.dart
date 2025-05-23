import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/salon_service.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/salon_team.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_state.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/about_salon_text.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/google_map.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:html';
import 'package:lexyapp/Features/Search%20Salons/Widget/image_carousel.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/rating_tile.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_basic_details.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/service_tile.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/services_list.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'google-maps-html',
        (int viewId) {
          final iframe = IFrameElement()
            ..src =
                'https://maps.google.com/maps?q=${widget.salon.location.latitude},${widget.salon.location.longitude}&hl=es&z=14&output=embed'
            ..style.border = '0';
          return iframe;
        },
      );
    }
  }

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
      "10:00 AM - 10:00 PM", // Sunday
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
              count: widget.salon.count,
            ),
          ),
          SalonBasicDetails(widget: widget, todayHours: todayHours),
          AboutSalonText(widget: widget),
          widget.salon.showPhoneNumber == true
              ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text(
                        'Call Us',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '+${widget.salon.phoneNumber?["countryCode"]} ${widget.salon.phoneNumber?["nsn"]}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final phoneNumber =
                            '+${widget.salon.phoneNumber?["countryCode"]}${widget.salon.phoneNumber?["nsn"]}';
                        final telUrl = "tel:$phoneNumber";

                        launchUrl(Uri.parse(telUrl));
                      },
                    ),
                  ),
                ),
              )
              : SliverToBoxAdapter(child: const SizedBox.shrink()),
          SliverToBoxAdapter(
            child: RatingsTile(
              averageRating: averageRating,
              salon: widget.salon,
              docID: widget.salonId,
            ),
          ),
          // CustomListTile(
          //   title: 'Team Members',
          //   subtitle: '${widget.salon.team.length} People Available',
          //   buttonText: 'View All',
          //   onTapButton: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) {
          //         return TeamMembersList(
          //           salon: widget.salon,
          //         );
          //       },
          //     ));
          //   },
          //   onTapTile: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) {
          //         return TeamMembersList(
          //           salon: widget.salon,
          //         );
          //       },
          //     ));
          //   },
          // ),
          CustomListTile(
            title: 'Services',
            subtitle: '${widget.salon.services.length} Services Available',
            buttonText: 'View All',
            onTapButton: () {
              if (widget.salon.showBooknow == true) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ServicesPage(
                        teamMembers: widget.salon.team,
                        salonId: widget.salonId,
                        servicesList: widget.salon.services,
                        salon: widget.salon,
                      );
                    },
                  ),
                );
              } else {
                showCustomSnackBar(
                  context,
                  "Bookins Not Available!",
                  "In App Bookins are currently not available!",
                );
              }
            },
            onTapTile: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ServicesPage(
                      salon: widget.salon,
                      salonId: widget.salonId,
                      teamMembers: widget.salon.team,
                      servicesList: widget.salon.services,
                    );
                  },
                ),
              );
            },
          ),

          ServicesList(widget: widget),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 15,
              right: 15,
              bottom: 5,
            ),
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
              child: kIsWeb
                  ? SizedBox(
                      height: 400,
                      child: HtmlElementView(viewType: 'google-maps-html'),
                    )
                  : LocationMap(
                      latitude: widget.salon.location.latitude,
                      longitude: widget.salon.location.longitude,
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        showCustomSnackBar(
                          context,
                          'Added to Favourites',
                          '${widget.salon.name} Added to Favourites!',
                        );
                      }
                      if (state is FavouritesError) {
                        showCustomSnackBar(
                          context,
                          isError: true,
                          'Already Added to Favourites',
                          '${widget.salon.name} is already added to favourites!',
                        );
                      }
                    },
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          showCustomModalBottomSheet(
                            context,
                            const SignUpPage(),
                            () => Navigator.of(context).pop(),
                          );
                        } else {
                          context.read<FavouritesCubit>().addSalonToFavourites(
                            widget.salonId,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.deepPurple,
                        size: 25,
                      ),
                      label: Text(
                        'Add to favourites',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                const SizedBox(width: 16),
                // Book Now Button
                (widget.salon.showBooknow == true)
                    ? Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            showCustomModalBottomSheet(
                              context,
                              const SignUpPage(),
                              () => Navigator.of(context).pop(),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ServicesPage(
                                      salon: widget.salon,
                                      salonId: widget.salonId,
                                      teamMembers: widget.salon.team,
                                      servicesList: widget.salon.services,
                                    ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
                    )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
