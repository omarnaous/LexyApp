import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_service.dart';

import 'appointment_model.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService = AppointmentService();

  Future<void> saveAppointment(
      {required String salonId,
      required AppointmentModel appointmentModel,
      required String ownerId}) async {
    // Fetch Salon details
    DocumentSnapshot salonSnapshot = await FirebaseFirestore.instance
        .collection('Salons')
        .doc(salonId)
        .get();

    if (!salonSnapshot.exists) {
      throw Exception("Salon not found");
    }

    await _appointmentService.saveAppointmentData(appointmentModel.toMap());
  }
}
