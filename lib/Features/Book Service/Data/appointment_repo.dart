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
    // Fetch Salon details
    DocumentSnapshot salonSnapshot = await FirebaseFirestore.instance
        .collection('Salons')
        .doc(salonId)
        .get();

    if (!salonSnapshot.exists) {
      throw Exception("Salon not found");
    }

    final salonData = salonSnapshot.data() as Map<String, dynamic>;
    final salonModel = Salon.fromMap(salonData);

    // Generate unique appointment ID
    final appointmentId =
        FirebaseFirestore.instance.collection('Appointments').doc().id;

    // Create the appointment model
    final appointment = AppointmentModel(
      appointmentId: appointmentId,
      userId: userId,
      salonId: salonId,
      salonModel: salonModel,
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
