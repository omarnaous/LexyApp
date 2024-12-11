import 'package:cloud_firestore/cloud_firestore.dart';

class Salon {
  final String name;
  final String about;
  final List<String> imageUrls;
  final GeoPoint location;
  final List<Review> reviews;
  final String city; // City field
  final List<ServiceModel> services; // Services list
  final List<String> favourites; // Favourites list
  final int count; // New count field
  final List<Team> team; // Team list
  final String ownerUid; // Owner UID field
  final bool active; // Active status field
  final List<String> workingDays; // Working days field
  final Timestamp openingTime; // Opening time field as Timestamp
  final Timestamp closingTime; // Closing time field as Timestamp

  Salon({
    required this.name,
    required this.about,
    required this.imageUrls,
    required this.location,
    required this.reviews,
    required this.city, // Include city in the constructor
    required this.services, // Include services in the constructor
    required this.favourites, // Include favourites in the constructor
    required this.count, // Include count in the constructor
    required this.team, // Include team in the constructor
    required this.ownerUid, // Include ownerUid in the constructor
    required this.active, // Include active in the constructor
    required this.workingDays, // Include working days in the constructor
    required this.openingTime, // Include opening time in the constructor
    required this.closingTime, // Include closing time in the constructor
  });

  // Convert a Salon object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'about': about,
      'imageUrls': imageUrls,
      'location': location,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'city': city,
      'services': services.map((service) => service.toMap()).toList(),
      'favourites': favourites, // Add favourites to the map
      'count': count, // Add count to the map
      'teamMembers':
          team.map((member) => member.toMap()).toList(), // Add team to the map
      'ownerUid': ownerUid, // Add ownerUid to the map
      'active': active, // Add active to the map
      'workingDays': workingDays, // Add working days to the map
      'openingTime': openingTime, // Add opening time to the map
      'closingTime': closingTime, // Add closing time to the map
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
      city: map['city'] ?? '',
      services: (map['services'] as List<dynamic>)
          .map((service) => ServiceModel.fromMap(service))
          .toList(),
      favourites: List<String>.from(
          map['favourites'] ?? []), // Retrieve favourites from the map
      count: map['count'] ?? 0, // Retrieve count from the map
      team: (map['teamMembers'] as List<dynamic>)
          .map((member) => Team.fromMap(member))
          .toList(), // Retrieve team from the map
      ownerUid: map['ownerUid'] ?? '', // Retrieve ownerUid from the map
      active: map['active'] ?? true, // Retrieve active status, default to true
      workingDays:
          List<String>.from(map['workingDays'] ?? []), // Retrieve working days
      openingTime:
          map['openingTime'] ?? Timestamp.now(), // Retrieve opening time
      closingTime:
          map['closingTime'] ?? Timestamp.now(), // Retrieve closing time
    );
  }
}

class Review {
  final String userId; // User identifier
  final String user; // User's name or display name
  final int rating; // Rating out of 5
  final String description; // Review text
  final DateTime date; // Date of the review

  Review({
    required this.userId,
    required this.user,
    required this.rating,
    required this.description,
    required this.date,
  });

  // Convert a Review object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'user': user,
      'rating': rating,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Create a Review object from a Firestore document snapshot
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? '',
      user: map['user'] ?? '',
      rating: map['rating'] ?? 0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ServiceModel {
  final String title; // Service title
  final int price; // Service price
  final String description; // Service description

  ServiceModel({
    required this.title,
    required this.price,
    required this.description,
  });

  // Convert a Service object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
    };
  }

  // Create a Service object from a Firestore document snapshot
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      title: map['title'] ?? '',
      price: map['price'] ?? 0,
      description: map['description'] ?? '',
    );
  }
}

class Team {
  final String name; // Team member's name
  final String imageLink; // Image link of the team member

  Team({
    required this.name,
    required this.imageLink,
  });

  // Convert a Team object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageLink': imageLink,
    };
  }

  // Create a Team object from a Firestore document snapshot
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'] ?? '',
      imageLink: map['imageLink'] ?? '',
    );
  }
}
