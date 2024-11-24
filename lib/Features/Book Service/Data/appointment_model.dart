import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class AppointmentModel {
  final String appointmentId;
  final String userId;
  final String salonId;
  final DateTime date;
  final List<ServiceModel> services;
  final double total;
  final String currency;
  final String paymentMethod;
  final Timestamp createdAt;
  final Salon salonModel;

  AppointmentModel({
    required this.appointmentId,
    required this.userId,
    required this.salonId,
    required this.date,
    required this.services,
    required this.total,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.createdAt,
    required this.salonModel,
  });

  // Convert the Appointment object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'salonId': salonId,
      'date':
          Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'services': services.map((service) => service.toMap()).toList(),
      'total': total,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
      'salonModel': salonModel.toMap(), // Convert Salon to a map
    };
  }

  // Factory method to create an Appointment object from Firestore data
  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map['appointmentId'] ?? '',
      userId: map['userId'] ?? '',
      salonId: map['salonId'] ?? '',
      date: (map['date'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
      services: (map['services'] as List<dynamic>)
          .map((item) => ServiceModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: map['total'] ?? 0.0,
      currency: map['currency'] ?? 'USD',
      paymentMethod: map['paymentMethod'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      salonModel: Salon.fromMap(
          map['salonModel'] as Map<String, dynamic>), // Deserialize Salon
    );
  }
}
