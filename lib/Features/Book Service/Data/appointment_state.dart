abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentSuccess extends AppointmentState {}

class AppointmentFailure extends AppointmentState {
  final String error;

  AppointmentFailure(this.error);
}
