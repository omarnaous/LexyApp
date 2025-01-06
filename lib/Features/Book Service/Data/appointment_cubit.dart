import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_repo.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  AppointmentCubit() : super(AppointmentInitial());

  Future<void> createAppointment({
    required String userId,
    required String salonId,
    required DateTime date,
    required List<Map<String, dynamic>> services,
    required double total,
    required String paymentMethod,
    required BuildContext context,
    required Salon salonModel,
    required String startTime, // New parameter for start time
    required String endTime, // New parameter for end time
    String currency = 'USD',
    String status = 'Pending',
  }) async {
    emit(AppointmentLoading());

    try {
      final appointment = AppointmentModel(
        appointmentId: '', // The repository or Firestore can generate this
        userId: userId,
        salonId: salonId,
        date: date,
        services: services,
        total: total,
        currency: currency,
        paymentMethod: paymentMethod,
        createdAt: Timestamp.now(),
        salonModel: salonModel,
        status: status,
        ownerId: salonModel.ownerUid,
        startTime: startTime, // Assign startTime
        endTime: endTime, // Assign endTime
      );

      await _appointmentRepository
          .saveAppointment(
        salonId: salonId,
        appointmentModel: appointment,
        ownerId: salonModel.ownerUid,
      )
          .whenComplete(() {
        BlocProvider.of<NavBarCubit>(context).showNavBar();
      });

      emit(AppointmentSuccess());
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }
}
