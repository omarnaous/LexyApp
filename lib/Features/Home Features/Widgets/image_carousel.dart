import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/custom_image.dart';

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
          return const Center(
            child: Text("No images available."),
          );
        }

        final images = snapshot.data!.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['imageUrl'] as String)
            .toList();

        return CarouselSlider(
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          items: images.map((imageUrl) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImage(imageUrl: imageUrl),
            );
          }).toList(),
        );
      },
    );
  }
}
