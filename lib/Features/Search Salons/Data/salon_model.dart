import 'package:cloud_firestore/cloud_firestore.dart';

class Salon {
  final String name;
  final String about;
  final List<String> imageUrls;
  final GeoPoint location;
  final List<Review> reviews;
  final String city; // New city field

  Salon({
    required this.name,
    required this.about,
    required this.imageUrls,
    required this.location,
    required this.reviews,
    required this.city, // Include city in the constructor
  });

  // Convert a Salon object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'about': about,
      'imageUrls': imageUrls,
      'location': location,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'city': city, // Add city to the map
    };
  }

  // Create a Salon object from a Firestore document snapshot
  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      name: map['name'] ?? '',
      about: map['about'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      location: map['location'] as GeoPoint,
      reviews: (map['reviews'] as List<dynamic>)
          .map((review) => Review.fromMap(review))
          .toList(),
      city: map['city'] ?? '', // Retrieve city from the map
    );
  }
}

class Review {
  final String userId; // User identifier
  final String user; // User's name or display name
  final int rating; // Rating out of 5
  final String description; // Review text

  Review({
    required this.userId,
    required this.user,
    required this.rating,
    required this.description,
  });

  // Convert a Review object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'user': user,
      'rating': rating,
      'description': description,
    };
  }

  // Create a Review object from a Firestore document snapshot
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? '',
      user: map['user'] ?? '',
      rating: map['rating'] ?? 0,
      description: map['description'] ?? '',
    );
  }
}
