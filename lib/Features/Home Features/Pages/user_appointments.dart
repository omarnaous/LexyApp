import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';

class AppointmentScheduler extends StatelessWidget {
  const AppointmentScheduler({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data!;
          final minDate = appointments
              .map((e) => e.date)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          final maxDate = appointments
              .map((e) => e.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);

          return SfCalendar(
            view: CalendarView.schedule,
            headerHeight: 0, // Completely hides the header
            scheduleViewMonthHeaderBuilder:
                (BuildContext context, ScheduleViewMonthHeaderDetails details) {
              final String monthName =
                  "${_getMonthName(details.date.month)} ${details.date.year}";

              return Container(
                height: 0, // Increased height for the month header
                color: Colors.deepPurple,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Month Name Centered
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        monthName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Increased font size for larger header
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Back Button at Top Left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // Navigate back
                        },
                      ),
                    ),
                  ],
                ),
              );
            },

            minDate: minDate,
            maxDate: maxDate,
            dataSource: CustomAppointmentDataSource(appointments),
            todayHighlightColor: Colors.deepPurple,
            appointmentTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Increased font size for appointment text
            ),
            onTap: (CalendarTapDetails details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final AppointmentData tappedAppointment =
                    details.appointments!.first as AppointmentData;

                // Map AppointmentData back to AppointmentModel
                final appointmentModel = appointments.firstWhere(
                  (appointment) =>
                      appointment.date == tappedAppointment.startTime &&
                      appointment.salonModel.name == tappedAppointment.subject,
                );

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return CheckOutPage(
                        teamMember: appointmentModel.salonModel.team[0],
                        date: appointmentModel.date,
                        salonId: appointmentModel.salonId,
                        services: appointmentModel.services);
                  },
                ));
              }
            },
          );
        },
      ),
    );
  }

  Stream<List<AppointmentModel>> _fetchAppointments() async* {
    final Stream<QuerySnapshot> snapshots =
        FirebaseFirestore.instance.collection('Appointments').snapshots();

    await for (final snapshot in snapshots) {
      yield snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppointmentModel.fromMap(data);
      }).toList();
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[month - 1];
  }
}

class CustomAppointmentDataSource extends CalendarDataSource {
  CustomAppointmentDataSource(List<AppointmentModel> appointments) {
    this.appointments = appointments.map((appointment) {
      return AppointmentData(
        startTime: appointment.date,
        endTime: appointment.date.add(const Duration(hours: 1)),
        subject: appointment.salonModel.name,
        color: Colors.deepPurple,
      );
    }).toList();
  }
}

class AppointmentData extends Appointment {
  AppointmentData({
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
  });
}
