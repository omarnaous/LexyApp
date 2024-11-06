import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomImage extends StatefulWidget {
  const CustomImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  final String imageUrl;
  final BoxFit fit;
  final double width;
  final double height;

  @override
  // ignore: library_private_types_in_public_api
  _CustomImageState createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      width: widget.width, // Ensure the image stretches horizontally
      height: widget.height, // Ensure the image stretches vertically
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.deepPurple.withOpacity(0.1),
        highlightColor: Colors.deepPurple.withOpacity(0.1),
        direction: ShimmerDirection.ltr,
        child: Container(
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
