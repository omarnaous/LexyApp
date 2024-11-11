import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_service.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

import 'appointment_model.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService = AppointmentService();

  Future<void> saveAppointment({
    required String userId,
    required String salonId,
    required DateTime date,
    required List<ServiceModel> services,
    required double total,
    required String paymentMethod,
    String currency = 'USD',
  }) async {
    // Create the appointment model
    final appointment = Appointment(
      appointmentId: '',
      userId: userId,
      salonId: salonId,
      date: date,
      services: services,
      total: total,
      currency: currency,
      paymentMethod: paymentMethod,
      createdAt: Timestamp.now(),
    );

    // Convert to map and use AppointmentService to save
    await _appointmentService.saveAppointmentData(appointment.toMap());
  }
}
