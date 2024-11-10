// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String firstName;
  final String? lastName;
  final String email;
  final String? password;
  final String phoneNumber;
  final String? imageUrl;
  final List<String>? favourites; // Favourites list
  final List<Map<String, dynamic>>? appointments; // Appointments list

  UserModel({
    required this.firstName,
    this.lastName,
    required this.email,
    this.password,
    required this.phoneNumber,
    this.imageUrl,
    this.favourites,
    this.appointments, // Initialize appointments
  });

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phoneNumber,
    String? imageUrl,
    List<String>? favourites,
    List<Map<String, dynamic>>?
        appointments, // Allow modification of appointments list
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      favourites: favourites ?? this.favourites,
      appointments: appointments ??
          this.appointments, // Preserve current appointments if not provided
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'favourites': favourites,
      'appointments': appointments, // Add appointments to the map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? "",
      email: map['email'] ?? "",
      password: map['password'] ?? "",
      phoneNumber: map['phoneNumber'] ?? "",
      imageUrl: map['imageUrl'] ?? "",
      favourites: List<String>.from(map['favourites'] ?? []),
      appointments: List<Map<String, dynamic>>.from(
          map['appointments'] ?? []), // Retrieve appointments from map
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(firstName: $firstName, lastName: $lastName, email: $email, password: $password, phoneNumber: $phoneNumber, imageUrl: $imageUrl, favourites: $favourites, appointments: $appointments)';
  }
}
