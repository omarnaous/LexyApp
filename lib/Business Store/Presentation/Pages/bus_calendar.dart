import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/custom_appt.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/salon_service.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';

class ScheduleBusinessPage extends StatefulWidget {
  const ScheduleBusinessPage({super.key});

  @override
  _ScheduleBusinessPageState createState() => _ScheduleBusinessPageState();
}

class _ScheduleBusinessPageState extends State<ScheduleBusinessPage> {
  bool isDailyView = false; // Track whether the current view is daily or weekly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Calendar")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Get the current user.
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            // Fetch the salon document where ownerUid matches the current user.
            final salonSnapshot =
                await FirebaseFirestore.instance
                    .collection('Salons')
                    .where('ownerUid', isEqualTo: currentUser.uid)
                    .get();

            if (salonSnapshot.docs.isNotEmpty) {
              // Get the first salon document data and create a Salon model.
              final docData = salonSnapshot.docs.first.data();
              final salonModel = Salon.fromMap(docData);
              // Navigate to CustomAppointmentPage with the fetched salon and current date.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CustomAppointmentPage(
                      salon: salonModel,
                      selectedDate: DateTime.now(),
                    );
                  },
                ),
              );
            } else {
              // Handle the case when no salon is found.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No salon found for this owner.")),
              );
            }
          }
        },
        label: Text(
          "Create Appointment",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !isDailyView ? Colors.deepPurple : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isDailyView = false;
                    });
                  },
                  child: const Text(
                    "Week View",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDailyView ? Colors.deepPurple : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isDailyView = true;
                    });
                  },
                  child: const Text(
                    "Day View",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchAppointmentsForOwner(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No appointments found."));
                }

                final appointmentsFuture = Future.wait(
                  snapshot.data!.docs.map((doc) async {
                    final data = doc.data() as Map<String, dynamic>;
                    final appointment = AppointmentModel.fromMap(data);

                    final username = await _fetchUsername(appointment.userId);
                    return appointment.copyWith(
                      salonModel: appointment.salonModel.copyWith(
                        name: username,
                      ),
                    );
                  }).toList(),
                );

                return FutureBuilder<List<AppointmentModel>>(
                  future: appointmentsFuture,
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (futureSnapshot.hasError) {
                      return Center(
                        child: Text("Error: ${futureSnapshot.error}"),
                      );
                    }

                    final appointments = futureSnapshot.data!;

                    return SfCalendar(
                      view: isDailyView ? CalendarView.day : CalendarView.week,
                      dataSource: CustomAppointmentDataSource(appointments),
                      todayHighlightColor: Colors.deepPurple,
                      appointmentTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                      onTap: (CalendarTapDetails details) {
                        if (details.appointments != null &&
                            details.appointments!.isNotEmpty) {
                          final tappedAppointment =
                              details.appointments!.first as AppointmentData;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return CheckOutPage(
                                  isEdit: true,
                                  isAdmin: true,
                                  appointmentId:
                                      tappedAppointment
                                          .appointmentModel
                                          .appointmentId,
                                  status:
                                      tappedAppointment.appointmentModel.status,
                                  services:
                                      tappedAppointment
                                          .appointmentModel
                                          .services,
                                  salonId:
                                      tappedAppointment
                                          .appointmentModel
                                          .salonId,
                                  date: tappedAppointment.appointmentModel.date,
                                  startTime:
                                      tappedAppointment
                                          .appointmentModel
                                          .startTime,
                                  endTime:
                                      tappedAppointment
                                          .appointmentModel
                                          .endTime,
                                  salon:
                                      tappedAppointment
                                          .appointmentModel
                                          .salonModel,
                                  requestedUserId:
                                      tappedAppointment.appointmentModel.userId,
                                );
                              },
                            ),
                          );
                        } else {
                          FirebaseFirestore.instance
                              .collection('Salons')
                              .where(
                                'ownerUid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid,
                              )
                              .get()
                              .then((value) {
                                Salon salonModel = Salon.fromMap(
                                  value.docChanges.first.doc.data()!,
                                );
                                // print(details.date);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CustomAppointmentPage(
                                        salon: salonModel,
                                        selectedDate: details.date,
                                      );
                                    },
                                  ),
                                );
                              });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _fetchAppointmentsForOwner() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in.");
    }
    return FirebaseFirestore.instance
        .collection('Appointments')
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  Future<String> _fetchUsername(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        return '${user.firstName} ${user.lastName}';
      }
      return "Unknown User";
    } catch (e) {
      return "Error";
    }
  }
}

class CustomAppointmentDataSource extends CalendarDataSource {
  DateTime? constructDateTimeFromStrings(
    String date,
    String time,
    String format,
  ) {
    try {
      String dateTimeString = '$date $time';
      return DateFormat(format).parse(dateTimeString);
    } catch (e) {
      print('Error constructing DateTime: $e');
      return null;
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

  String getServicesAndTeamMembers(AppointmentModel appointment) {
    try {
      return appointment.services
          .map((serviceEntry) {
            final service = serviceEntry['service'] as ServiceModel;
            final teamMember = serviceEntry['teamMember'] as Team;
            final serviceName = service.title;
            final teamMemberName = teamMember.name;
            return "$serviceName by $teamMemberName";
          })
          .join(', ');
    } catch (e) {
      print('Error constructing services string: $e');
      return 'Service details unavailable';
    }
  }

  CustomAppointmentDataSource(List<AppointmentModel> appointments) {
    this.appointments =
        appointments.map((appointment) {
          String date = extractDateFromDateTime(appointment.date);
          String startTime = appointment.startTime;
          String endTime = appointment.endTime;
          String format = "d MMMM yyyy h:mm a";

          String servicesAndTeamMembers = getServicesAndTeamMembers(
            appointment,
          );

          // Here we calculate the actual start and end times
          DateTime actualStartTime =
              constructDateTimeFromStrings(date, startTime, format)!;
          DateTime actualEndTime =
              constructDateTimeFromStrings(date, endTime, format)!;

          // Calculate the duration of the appointment
          Duration duration = actualEndTime.difference(actualStartTime);

          // If the appointment is less than 1 hour, extend it visually to 1 hour
          DateTime visualEndTime;
          if (duration.inMinutes < 60) {
            visualEndTime = actualStartTime.add(
              const Duration(hours: 1),
            ); // Extend visually to 1 hour
          } else {
            visualEndTime =
                actualEndTime; // Keep the real end time for appointments >= 1 hour
          }

          return AppointmentData(
            startTime: actualStartTime,
            endTime: visualEndTime, // Use visual adjusted end time if < 1 hour
            subject:
                "${appointment.salonModel.name} - ${appointment.status} "
                "Time: ${DateFormat.jm().format(actualStartTime)} - ${DateFormat.jm().format(visualEndTime)} "
                "$servicesAndTeamMembers",
            color: _getStatusColor(appointment.status),
            appointmentModel: appointment,
          );
        }).toList();
  }

  @override
  DateTime getStartTime(int index) => appointments?[index].startTime;
  @override
  DateTime getEndTime(int index) => appointments?[index].endTime;
  @override
  String getSubject(int index) => appointments?[index].subject;
  @override
  Color getColor(int index) => appointments?[index].color;

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
    required this.appointmentModel,
  });
}
