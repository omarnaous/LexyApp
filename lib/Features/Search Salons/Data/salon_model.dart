// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class Salon {
  final String name;
  final String about;
  final List<String> imageUrls;
  final GeoPoint location;
  final List<Review> reviews;
  final String city;
  final List<ServiceModel> services;
  final List<String> favourites;
  final int count;
  final List<Team> team;
  final String ownerUid;
  final bool active;
  final List<String> workingDays;
  final Timestamp openingTime;
  final Timestamp closingTime;
  final Map<String, dynamic> workingHours;
  final List<dynamic>? categories;
  final Map<String, dynamic>? phoneNumber;
  final bool? showPhoneNumber;
  final bool? showBooknow;

  Salon({
    required this.name,
    this.categories,
    this.phoneNumber,
    required this.about,
    required this.imageUrls,
    required this.location,
    required this.reviews,
    required this.city,
    required this.services,
    required this.favourites,
    required this.count,
    required this.team,
    required this.ownerUid,
    required this.active,
    required this.workingDays,
    required this.openingTime,
    required this.closingTime,
    required this.workingHours,
    this.showPhoneNumber = false,
    this.showBooknow = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'about': about,
      'imageUrls': imageUrls,
      'location': location,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'city': city,
      'services': services.map((service) => service.toMap()).toList(),
      'favourites': favourites,
      'count': count,
      'teamMembers': team.map((member) => member.toMap()).toList(),
      'ownerUid': ownerUid,
      'active': active,
      'workingDays': workingDays,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'workingHours': workingHours,
      'categories': categories,
      'phoneNumber': phoneNumber ?? {},
      'showPhoneNumber': showPhoneNumber ?? false,
      'showBooknow': showBooknow ?? false,
    };
  }

  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? {},
      categories: map['categories'],
      about: map['about'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      location: map['location'] as GeoPoint,
      reviews:
          (map['reviews'] as List<dynamic>)
              .map((review) => Review.fromMap(review))
              .toList(),
      city: map['city'] ?? '',
      services:
          (map['services'] as List<dynamic>)
              .map((service) => ServiceModel.fromMap(service))
              .toList(),
      favourites: List<String>.from(map['favourites'] ?? []),
      count: map['count'] ?? 0,
      team:
          (map['teamMembers'] as List<dynamic>)
              .map((member) => Team.fromMap(member))
              .toList(),
      ownerUid: map['ownerUid'] ?? '',
      active: map['active'] ?? true,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      openingTime: map['openingTime'] ?? Timestamp.now(),
      closingTime: map['closingTime'] ?? Timestamp.now(),
      workingHours: map['workingHours'],
      showPhoneNumber: map['showPhoneNumber'] ?? false,
      showBooknow: map['showBooknow'] ?? false,
    );
  }

  Salon copyWith({
    String? name,
    String? about,
    List<String>? imageUrls,
    GeoPoint? location,
    List<Review>? reviews,
    String? city,
    List<ServiceModel>? services,
    List<String>? favourites,
    int? count,
    List<Team>? team,
    String? ownerUid,
    bool? active,
    List<String>? workingDays,
    Timestamp? openingTime,
    Timestamp? closingTime,
    Map<String, dynamic>? phoneNumber,
    Map<String, Map<String, Timestamp>>? workingHours,
    bool? showPhoneNumber,
    bool? showBooknow,
  }) {
    return Salon(
      name: name ?? this.name,
      about: about ?? this.about,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      reviews: reviews ?? this.reviews,
      city: city ?? this.city,
      services: services ?? this.services,
      favourites: favourites ?? this.favourites,
      count: count ?? this.count,
      team: team ?? this.team,
      ownerUid: ownerUid ?? this.ownerUid,
      active: active ?? this.active,
      workingDays: workingDays ?? this.workingDays,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      workingHours: workingHours ?? this.workingHours,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showBooknow: showBooknow ?? this.showBooknow,
    );
  }
}

class Review {
  final String userId;
  final String user;
  final int rating;
  final String description;
  final DateTime date;

  Review({
    required this.userId,
    required this.user,
    required this.rating,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'user': user,
      'rating': rating,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? '',
      user: map['user'] ?? '',
      rating: map['rating'] ?? 0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Add copyWith
  Review copyWith({
    String? userId,
    String? user,
    int? rating,
    String? description,
    DateTime? date,
  }) {
    return Review(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

class ServiceModel {
  final String title;
  final String category;
  final num price;
  final String description;
  final num duration; // Required duration field
  final List<Team>? teamMembers; // Optional field

  // Constructor should handle teamMembers properly
  ServiceModel({
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.duration,
    this.teamMembers,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'price': price,
      'description': description,
      'duration': duration, // Include required duration
      'teamMembers': teamMembers?.map((team) => team.toMap()),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      title: map['title'] ?? '',
      price: map['price'] ?? 0,
      category: map['category'],
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0, // Ensure duration is always set
      teamMembers:
          map['teamMembers'] != null
              ? List<Team>.from(
                map['teamMembers'].map((team) => Team.fromMap(team)),
              )
              : null, // Handle nullable teamMembers
    );
  }

  // Add copyWith method to allow modification of fields
  ServiceModel copyWith({
    String? category,
    String? title,
    num? price,
    String? description,
    num? duration, // Required duration field
    List<Team>? teamMembers, // Nullable field
  }) {
    return ServiceModel(
      category: category ?? this.category,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      duration: duration ?? this.duration, // Update duration if provided
      teamMembers:
          teamMembers ?? this.teamMembers, // Update teamMembers if provided
    );
  }
}

class Team {
  final String name;
  final String imageLink;
  final String? description;
  final String? color; // Nullable color property

  Team({
    required this.name,
    required this.imageLink,
    this.description,
    this.color, // Nullable color field
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageLink': imageLink,
      'description': description,
      'color': color ?? '#000000', // Default to black if color is null
    };
  }

  // Create Team instance from Map
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'] ?? '',
      imageLink: map['imageLink'] ?? '',
      description: map['description'],
      color: map['color'], // Nullable color
    );
  }

  // Add copyWith method
  Team copyWith({
    String? name,
    String? imageLink,
    String? description,
    String? color,
  }) {
    return Team(
      name: name ?? this.name,
      imageLink: imageLink ?? this.imageLink,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  String toString() => name;
}
