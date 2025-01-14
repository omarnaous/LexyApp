import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';

class AppointmentScheduler extends StatelessWidget {
  const AppointmentScheduler({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
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
          final now = DateTime.now();
          final minDate = DateTime(now.year, now.month, 1);
          final maxDate = DateTime(now.year, now.month + 1, 0);

          return SfCalendar(
              view: CalendarView.day,
              headerHeight: 0,
              scheduleViewMonthHeaderBuilder: (BuildContext context,
                  ScheduleViewMonthHeaderDetails details) {
                final String monthName =
                    "${_getMonthName(details.date.month)} ${details.date.year}";

                return Container(
                  height: 50,
                  color: Colors.deepPurple,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          monthName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
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
                fontSize: 14,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  final tappedAppointmentData =
                      details.appointments!.first as AppointmentData;
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return CheckOutPage(
                        startTime:
                            tappedAppointmentData.appointmentModel.startTime,
                        endTime: tappedAppointmentData.appointmentModel.endTime,
                        appointmentId: tappedAppointmentData
                            .appointmentModel.appointmentId,
                        status: tappedAppointmentData.appointmentModel.status,
                        services:
                            tappedAppointmentData.appointmentModel.services,
                        salonId: tappedAppointmentData.appointmentModel.salonId,
                        date: tappedAppointmentData.appointmentModel.date,
                        salon:
                            tappedAppointmentData.appointmentModel.salonModel,
                      );
                    },
                  ));
                }
              });
        },
      ),
    );
  }

  Stream<List<AppointmentModel>> _fetchAppointments() async* {
    final Stream<QuerySnapshot> snapshots = FirebaseFirestore.instance
        .collection('Appointments')
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

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

String extractDateFromDateTime(DateTime dateTime) {
  try {
    return DateFormat('d MMMM yyyy').format(dateTime);
  } catch (e) {
    print('Error extracting date: $e');
    return '';
  }
}

DateTime? constructDateTimeFromStrings(
    String date, String time, String format) {
  try {
    // Combine the date and time strings
    String dateTimeString = '$date $time';

    // Parse the combined string into a DateTime object
    return DateFormat(format).parse(dateTimeString);
  } catch (e) {
    print('Error constructing DateTime: $e');
    return null;
  }
}

class CustomAppointmentDataSource extends CalendarDataSource {
  CustomAppointmentDataSource(List<AppointmentModel> appointments) {
    this.appointments = appointments.map((appointment) {
      String date =
          extractDateFromDateTime(appointment.date); // Date as a string
      String startTime = appointment.startTime; // Start time as a string
      String endTime = appointment.endTime; // End time as a string
      String format = "d MMMM yyyy h:mm a";
      final startDateTime =
          constructDateTimeFromStrings(date, startTime, format)!;
      final endDateTime = constructDateTimeFromStrings(date, endTime, format)!;
      final isShortAppointment =
          endDateTime.difference(startDateTime).inMinutes < 60;
      return AppointmentData(
        startTime: startDateTime,
        endTime: isShortAppointment
            ? startDateTime.add(Duration(hours: 1))
            : endDateTime,
        subject: isShortAppointment
            ? "${appointment.salonModel.name} - ${appointment.status} (${endDateTime.difference(startDateTime).inMinutes} mins)"
            : "${appointment.salonModel.name} - ${appointment.status}",
        color: _getStatusColor(appointment.status),
        appointmentModel: appointment,
      );
    }).toList();
  }

  @override
  DateTime getStartTime(int index) {
    return appointments?[index].startTime ?? DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    return appointments?[index].endTime ??
        DateTime.now().add(Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    return appointments?[index].subject ?? "No Subject";
  }

  @override
  String getLocation(int index) {
    return '';
  }

  @override
  Color getColor(int index) {
    return appointments?[index].color ?? Colors.grey;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Waiting Approval':
        return Colors.blue;
      case 'Cancelled by Client':
        return Colors.red;
      case 'Rejected':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class AppointmentData extends Appointment {
  final AppointmentModel appointmentModel;

  AppointmentData({
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
    required this.appointmentModel, // Add AppointmentModel as a required parameter
  });

  String get salonName => appointmentModel.salonModel
      .name; // Assuming you need the salon name from AppointmentModel
}
