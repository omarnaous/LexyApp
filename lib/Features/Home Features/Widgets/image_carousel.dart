import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';
import 'package:lexyapp/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SlidingImagesSection extends StatelessWidget {
  const SlidingImagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No images available."));
        }

        // Extract the necessary fields from the Firestore documents
        final banners =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'url': data['url'] as String, // Image URL
                'link': data['link'] as String? ?? '', // Title (optional)
                'salonId': data['salonId'] as String? ?? '', // Title (optional)
              };
            }).toList();

        return CarouselSlider(
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          items:
              banners.map((banner) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      if (banner['link'] != '') {
                        launchUrl(Uri.parse(banner['link']!));
                      } else if (banner['salonId'] != '') {
                        FirebaseFirestore.instance
                            .collection('Salons')
                            .doc('1S8FSvplUzbxP0Nvx1dZ')
                            .get()
                            .then((value) {
                              final data = value.data() as Map<String, dynamic>;
                              final salon = Salon.fromMap(data);
                              final salonId = value.id;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SalonDetailsPage(
                                      salon: salon,
                                      salonId: salonId,
                                    );
                                  },
                                ),
                              );
                            });
                      }
                    },
                    child: Stack(
                      children: [
                        CustomImage(imageUrl: banner['url']!), // Show the image
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
