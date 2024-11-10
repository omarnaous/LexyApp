// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';

class SalonImagesCarousel extends StatefulWidget {
  const SalonImagesCarousel({
    super.key,
    required this.imageUrls,
    required this.currentCarouselIndex,
    required this.count,
  });

  final List<String> imageUrls;
  final int currentCarouselIndex;
  final int count;

  @override
  SalonImagesCarouselState createState() => SalonImagesCarouselState();
}

class SalonImagesCarouselState extends State<SalonImagesCarousel> {
  int currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    currentCarouselIndex = widget.currentCarouselIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 400,
            autoPlay: false,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                currentCarouselIndex = index;
              });
            },
          ),
          itemCount: widget.imageUrls.length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                widget.imageUrls[itemIndex],
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
            );
          },
        ),
        Positioned(
          left: 16,
          right: 16,
          child: SafeArea(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<NavBarCubit>().showNavBar();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.white,
                    elevation: 2,
                  ),
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentCarouselIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentCarouselIndex == index
                      ? Colors.deepPurple
                      : Colors.grey,
                ),
              );
            }),
          ),
        ),
        // Likes display card with shadow
        Positioned(
          bottom: 20,
          right: 16,
          child: Card(
            color: Colors.black.withOpacity(0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.deepPurple.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.count} likes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
