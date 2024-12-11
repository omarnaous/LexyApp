// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    Key? key,
    required this.teamMembers,
    required this.salonId,
    required this.services,
    required this.salonModel,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Team? _selectedTeamMember;
  DateTime _selectedDate = DateTime.now();
  int? _selectedTimeIndex;

  List<String> workingDays = [];
  int openingHour = 9; // Default opening hour
  int closingHour = 18; // Default closing hour

  @override
  void initState() {
    super.initState();
    _fetchSalonDetails();
    if (!widget.teamMembers.any((member) => member.name == "Anyone")) {
      widget.teamMembers.insert(0, Team(name: "Anyone", imageLink: ""));
    }
    _selectedTeamMember = widget.teamMembers.first;
  }

  Future<void> _fetchSalonDetails() async {
    final salonDoc = await FirebaseFirestore.instance
        .collection('Salons')
        .doc(widget.salonId)
        .get();

    if (salonDoc.exists) {
      final data = salonDoc.data()!;
      setState(() {
        workingDays = List<String>.from(data['workingDays'] ?? []);
        final openingTime = data['openingTime'];
        final closingTime = data['closingTime'];

        if (openingTime is Timestamp) {
          openingHour = openingTime.toDate().hour;
        } else if (openingTime is String) {
          openingHour = int.parse(openingTime.split(':')[0]);
        }

        if (closingTime is Timestamp) {
          closingHour = closingTime.toDate().hour;
        } else if (closingTime is String) {
          closingHour = int.parse(closingTime.split(':')[0]);
        }
      });
    }
  }

  List<int> _getDynamicTimings() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final effectiveStartHour = isToday ? now.hour : openingHour;
    return List.generate(
      (closingHour - effectiveStartHour + 1).clamp(0, 24),
      (index) => effectiveStartHour + index,
    );
  }

  String formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:00 $period';
  }

  DateTime getSelectedDateTime(int hour) {
    return _selectedDate.copyWith(hour: hour, minute: 0);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  bool isWorkingDay(DateTime date) {
    final dayName = DateFormat('EEEE').format(date); // Full day name
    return workingDays
        .map((day) => day.toLowerCase())
        .contains(dayName.toLowerCase());
  }

  void showCustomSnackBar(BuildContext context, String title, String message,
      {bool isError = false}) {
    Color backgroundColor = isError ? Colors.red : Colors.deepPurple;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamicTimings = _getDynamicTimings();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Booking Time"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final List<String> appointmentList = [];

          if (snapshot.data != null) {
            for (var appointment in snapshot.data!.docs) {
              AppointmentModel appointmentModel = AppointmentModel.fromMap(
                appointment.data() as Map<String, dynamic>,
              );
              if (appointmentModel.salonId == widget.salonId) {
                final formattedDate = formatDateTime(appointmentModel.date);
                appointmentList.add(formattedDate);
              }
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWeeklyCalendar(
                  onDateSelected: (selectedDate) {
                    if (!isWorkingDay(selectedDate)) {
                      showCustomSnackBar(
                          context,
                          'Sorry we are closed on this day!',
                          'We are open from ${workingDays[0]} to ${workingDays[workingDays.length - 1]}'
                          // openingHour,
                          // closingHour,
                          // isError: true,
                          );
                      return;
                    }
                    setState(() {
                      _selectedDate = selectedDate;
                      _selectedTimeIndex = null; // Reset time selection
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dynamicTimings.length,
                  itemBuilder: (context, index) {
                    final hour = dynamicTimings[index];
                    final selectedDateTime = getSelectedDateTime(hour);
                    final isTaken = appointmentList
                        .contains(formatDateTime(selectedDateTime));

                    return TimeListTile(
                      filteredTimings:
                          dynamicTimings.map((e) => formatHour(e)).toList(),
                      selectedTimeIndex:
                          _selectedTimeIndex ?? -1, // Handle null
                      index: index,
                      isTaken: isTaken,
                      onTap: () {
                        setState(() {
                          _selectedTimeIndex = index;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _selectedTimeIndex == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  final selectedDateTime =
                      getSelectedDateTime(dynamicTimings[_selectedTimeIndex!]);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckOutPage(
                        date: selectedDateTime,
                        salonId: widget.salonId,
                        services: widget.services,
                        salon: widget.salonModel,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}
