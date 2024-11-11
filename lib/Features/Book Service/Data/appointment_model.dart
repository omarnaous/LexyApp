import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class Appointment {
  final String appointmentId;
  final String userId;
  final String salonId;
  final DateTime date;
  final List<ServiceModel> services;
  final double total;
  final String currency;
  final String paymentMethod;
  final Timestamp createdAt;

  Appointment({
    required this.appointmentId,
    required this.userId,
    required this.salonId,
    required this.date,
    required this.services,
    required this.total,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.createdAt,
  });

  // Convert the Appointment object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'salonId': salonId,
      'date': date,
      'services': services.map((service) => service.toMap()).toList(),
      'total': total,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
    };
  }

  // Factory method to create an Appointment object from Firestore data
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointmentId'],
      userId: map['userId'],
      salonId: map['salonId'],
      date: (map['date'] as Timestamp).toDate(),
      services: (map['services'] as List<dynamic>)
          .map((item) => ServiceModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: map['total'],
      currency: map['currency'] ?? 'USD',
      paymentMethod: map['paymentMethod'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}

// Assuming you already have a Service model with a toMap method and fromMap factory method
class Service {
  final String title;
  final String description;
  final double price;

  Service({
    required this.title,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      title: map['title'],
      description: map['description'],
      price: map['price'],
    );
  }
}
