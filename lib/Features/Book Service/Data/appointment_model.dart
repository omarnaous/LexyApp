import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class AppointmentModel {
  final String appointmentId;
  final String userId;
  final String salonId;
  final DateTime date;
  final List<Map<String, dynamic>>
      services; // List of maps with ServiceModel and Team
  final double total;
  final String currency;
  final String paymentMethod;
  final Timestamp createdAt;
  final Salon salonModel;
  final String status; // Appointment status
  final String ownerId; // New field for Owner ID
  final String startTime; // Appointment start time
  final String endTime; // Appointment end time

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
    this.status = 'Pending', // Default status
    required this.ownerId, // New required field
    required this.startTime, // New required field
    required this.endTime, // New required field
  });

  // Convert the Appointment object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'salonId': salonId,
      'date':
          Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'services': services.map((item) {
        return {
          'service': (item['service'] as ServiceModel).toMap(),
          'teamMember': (item['teamMember'] as Team).toMap(),
        };
      }).toList(),
      'total': total,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
      'salonModel': salonModel.toMap(), // Convert Salon to a map
      'status': status,
      'ownerId': ownerId, // Include ownerId
      'startTime': startTime, // Include startTime
      'endTime': endTime, // Include endTime
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
      services: (map['services'] as List<dynamic>).map((item) {
        final serviceMap = item['service'] as Map<String, dynamic>;
        final teamMemberMap = item['teamMember'] as Map<String, dynamic>;
        return {
          'service': ServiceModel.fromMap(serviceMap),
          'teamMember': Team.fromMap(teamMemberMap),
        };
      }).toList(),
      total: map['total'] ?? 0.0,
      currency: map['currency'] ?? 'USD',
      paymentMethod: map['paymentMethod'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      salonModel: Salon.fromMap(map['salonModel'] as Map<String, dynamic>),
      status: map['status'] ?? 'Pending',
      ownerId: map['ownerId'] ?? '', // Retrieve ownerId
      startTime: map['startTime'] ?? '', // Retrieve startTime
      endTime: map['endTime'] ?? '', // Retrieve endTime
    );
  }

  // CopyWith method for creating a modified copy of the object
  AppointmentModel copyWith({
    String? appointmentId,
    String? userId,
    String? salonId,
    DateTime? date,
    List<Map<String, dynamic>>? services,
    double? total,
    String? currency,
    String? paymentMethod,
    Timestamp? createdAt,
    Salon? salonModel,
    String? status,
    String? ownerId,
    String? startTime,
    String? endTime,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      userId: userId ?? this.userId,
      salonId: salonId ?? this.salonId,
      date: date ?? this.date,
      services: services ?? this.services,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      salonModel: salonModel ?? this.salonModel,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
