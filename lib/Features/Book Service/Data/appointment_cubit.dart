import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_repo.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  AppointmentCubit() : super(AppointmentInitial());

  Future<void> createAppointment({
    required String userId,
    required String salonId,
    required DateTime date,
    required List<ServiceModel> services,
    required double total,
    required String paymentMethod,
    required BuildContext context,
    String currency = 'USD',
  }) async {
    emit(AppointmentLoading());

    try {
      await _appointmentRepository
          .saveAppointment(
        userId: userId,
        salonId: salonId,
        date: date,
        services: services,
        total: total,
        paymentMethod: paymentMethod,
        currency: currency,
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
