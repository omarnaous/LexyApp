import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppointmentService {
  final CollectionReference appointmentsRef =
      FirebaseFirestore.instance.collection('Appointments');

  Future<void> saveAppointmentData(Map<String, dynamic> appointmentData) async {
    try {
      String appointmentId = appointmentsRef.doc().id;
      appointmentData['appointmentId'] = appointmentId;
      appointmentData['createdAt'] = FieldValue.serverTimestamp();

      await appointmentsRef.doc(appointmentId).set(appointmentData);

      if (kDebugMode) {
        print('Appointment saved successfully with ID: $appointmentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save appointment: $e');
      }
      throw Exception('Failed to save appointment');
    }
  }
}
