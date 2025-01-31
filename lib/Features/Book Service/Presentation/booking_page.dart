import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/custom_calendar.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/time_list.dart';

class BookingPage extends StatefulWidget {
  final List<Team> teamMembers;
  final String salonId;
  final List<Map<String, dynamic>> services;
  final Salon salonModel;

  const BookingPage({
    super.key,
    required this.teamMembers,
    required this.salonId,
    required this.services,
    required this.salonModel,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<String> hours = [];
  List<dynamic> isTaken = [];
  int selectedIndex = -1; // Start with no selection
  DateTime? selectedDate;
  List<AppointmentModel> appointments = [];

  @override
  void initState() {
    super.initState();
    String today = DateFormat('EEEE').format(DateTime.now());
    selectedDate = DateTime.now(); // Initialize with the current date
    updateAvailableHours(today);
    fetchAppointments(); // Fetch appointments once when page is initialized
  }

  Future<void> fetchAppointments() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .get();

      setState(() {
        appointments = snapshot.docs
            .map((doc) =>
                AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Error', 'Failed to fetch appointments.');
    }
  }

  List<String> generate15MinuteTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;
        String timeSlot =
            '$displayHour:${minute.toString().padLeft(2, '0')} $period';
        timeSlots.add(timeSlot);
      }
    }
    return timeSlots;
  }

  String calculateEndTime(
      String startTime, double duration, List<String> timeSlots) {
    List<String> timeParts = startTime.split(" ");
    bool isPM = timeParts[1] == "PM";
    List<String> hourMinute = timeParts[0].split(":");
    int startHour = int.parse(hourMinute[0]) % 12;
    int startMinute = int.parse(hourMinute[1]);

    if (isPM) startHour += 12;

    int totalMinutes = startHour * 60 + startMinute + duration.toInt();
    int endHour = (totalMinutes ~/ 60) % 24;
    int endMinute = totalMinutes % 60;

    String period = endHour >= 12 ? "PM" : "AM";
    endHour = endHour % 12 == 0 ? 12 : endHour % 12;

    return "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')} $period";
  }

  void updateAvailableHours(String dayName) async {
    try {
      DocumentSnapshot salonSnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .doc(widget.salonId)
          .get();

      Salon salon = Salon.fromMap(salonSnapshot.data() as Map<String, dynamic>);

      if (!salon.workingDays.contains(dayName)) {
        showCustomSnackBar(
            context, 'We are closed!', 'Sorry, we are closed on $dayName');
        setState(() {
          hours = [];
          isTaken = [];
        });
        return;
      }

      int openingIndex = generate15MinuteTimeSlots()
          .indexOf(salon.workingHours[dayName]['opening']);
      int closingIndex = generate15MinuteTimeSlots()
          .indexOf(salon.workingHours[dayName]['closing']);

      if (openingIndex < 0 || closingIndex < 0) {
        setState(() {
          hours = [];
          isTaken = [];
        });
        return;
      }

      List<String> updatedHours =
          generate15MinuteTimeSlots().sublist(openingIndex, closingIndex);
      List<dynamic> updatedIsTaken = List.filled(updatedHours.length, null);
      DateTime now = DateTime.now();

      if (dayName == DateFormat('EEEE').format(now)) {
        for (int i = 0; i < updatedHours.length; i++) {
          DateTime slotTime = DateFormat('h:mm a').parse(updatedHours[i]);
          slotTime = DateTime(
              now.year, now.month, now.day, slotTime.hour, slotTime.minute);
          if (slotTime.isBefore(now)) {
            updatedIsTaken[i] = "Not available";
          }
        }
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .get();

      for (var appointment in snapshot.docs) {
        AppointmentModel appointmentModel = AppointmentModel.fromMap(
            appointment.data() as Map<String, dynamic>);

        // Only update if the status is not "Cancelled by Client" or "Rejected"
        if (appointmentModel.status != "Cancelled by Client" &&
            appointmentModel.status != "Rejected") {
          List<String> desiredTeamMemberNames = widget.services
              .map((service) => (service['teamMember'] as Team).name)
              .toList();

          List<String> appointmentTeamMemberNames = appointmentModel.services
              .map((service) => (service['teamMember'] as Team).name)
              .toList();

          List<String> conflictingMembers = desiredTeamMemberNames
              .where((desired) => appointmentTeamMemberNames.contains(desired))
              .toList();

          if (conflictingMembers.isNotEmpty &&
              DateFormat('d MMMM yyyy').format(appointmentModel.date) ==
                  DateFormat('d MMMM yyyy').format(selectedDate!)) {
            String startTime = removeLeadingZero(appointmentModel.startTime);
            String endTime = removeLeadingZero(appointmentModel.endTime);

            int startIndex = updatedHours.indexOf(startTime);
            int endIndex = updatedHours.indexOf(endTime);

            if (startIndex >= 0) {
              updatedIsTaken[startIndex] = conflictingMembers.join(', ');
              if (endIndex > startIndex) {
                for (int i = startIndex; i <= endIndex; i++) {
                  updatedIsTaken[i] = conflictingMembers.join(', ');
                }
              }
            }
          }
        }
      }

      setState(() {
        hours = updatedHours;
        isTaken = updatedIsTaken;
      });
    } catch (e) {
      showCustomSnackBar(
          context, 'Error', 'Failed to fetch working hours or appointments.');
      setState(() {
        hours = [];
        isTaken = [];
      });
    }
  }

// Function to remove leading zero from time format
  String removeLeadingZero(String time) {
    List<String> timeParts = time.split(':');
    String hour = timeParts[0];
    String minute = timeParts[1].split(' ')[0];
    String period = timeParts[1].split(' ')[1];

    // Remove the leading zero if the hour is '09'
    if (hour.startsWith('0')) {
      hour = hour.substring(1);
    }

    return '$hour:$minute $period';
  }

  void showCustomSnackBar(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Booking Time"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWeeklyCalendar(
              onDateSelected: (selectedDate) {
                String dayName = DateFormat('EEEE').format(selectedDate);
                setState(() {
                  this.selectedDate = selectedDate;
                });
                updateAvailableHours(dayName);
              },
            ),
            const SizedBox(height: 16),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: hours.length,
              itemBuilder: (context, index) {
                return TimeListTile(
                  filteredTimings: hours,
                  selectedTimeIndex: selectedIndex,
                  index: index,
                  isTaken: isTaken[index] != null,
                  additionalInfo: isTaken[index]?.toString() ?? '',
                  onTap: () {
                    if (isTaken[index] == null) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedIndex == -1 || selectedDate == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    double totalDuration = 0;

                    for (var element in widget.services) {
                      ServiceModel serviceModel = element["service"];
                      totalDuration += serviceModel.duration;
                    }

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return CheckOutPage(
                          services: widget.services,
                          salonId: widget.salonId,
                          date: selectedDate!,
                          salon: widget.salonModel,
                          startTime: hours[selectedIndex],
                          status: 'Needs Checkout',
                          endTime: calculateEndTime(
                              hours[selectedIndex], totalDuration, hours),
                        );
                      },
                    ));
                  },
                  child: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
