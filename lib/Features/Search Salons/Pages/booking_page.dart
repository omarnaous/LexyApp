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
  final List<ServiceModel> services;

  const BookingPage({
    super.key,
    required this.teamMembers,
    required this.salonId,
    required this.services,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Team? _selectedTeamMember;
  DateTime _selectedDate = DateTime.now();
  int? _selectedTimeIndex;

  // Dynamic range for timings
  final int startHour = 5; // Starting hour
  final int endHour = 20; // Ending hour

  List<int> _getDynamicTimings() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final effectiveStartHour = isToday ? now.hour : startHour;
    return List.generate(endHour - effectiveStartHour + 1,
        (index) => effectiveStartHour + index);
  }

  String formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:00 $period';
  }

  @override
  void initState() {
    super.initState();
    // Add "Anyone" to the team member list if not already present
    if (!widget.teamMembers.any((member) => member.name == "Anyone")) {
      widget.teamMembers.insert(0, Team(name: "Anyone", imageLink: ""));
    }
    // Set the default selected team member to "Anyone"
    _selectedTeamMember = widget.teamMembers.first;
  }

  DateTime getSelectedDateTime(int hour) {
    return _selectedDate.copyWith(hour: hour, minute: 0);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
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
                // Custom Weekly Calendar for Date Selection
                CustomWeeklyCalendar(
                  onDateSelected: (selectedDate) {
                    setState(() {
                      _selectedDate = selectedDate;
                      _selectedTimeIndex = null; // Reset time selection
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Team Member Dropdown Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<Team>(
                    value: _selectedTeamMember,
                    decoration: InputDecoration(
                      labelText: "Select Team Member",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    items: widget.teamMembers.map((member) {
                      return DropdownMenuItem<Team>(
                        value: member,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundImage: member.imageLink.isNotEmpty
                                  ? NetworkImage(member.imageLink)
                                  : null,
                              backgroundColor: member.imageLink.isNotEmpty
                                  ? Colors.transparent
                                  : Colors.grey,
                              child: member.imageLink.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(member.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTeamMember = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Time Selector
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
                      selectedTimeIndex: _selectedTimeIndex,
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
                  print(
                      "Selected DateTime: ${formatDateTime(selectedDateTime)}");
                  print("Selected Team Member: ${_selectedTeamMember?.name}");
                  // Navigate to checkout page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckOutPage(
                        teamMember: _selectedTeamMember!,
                        date: selectedDateTime,
                        salonId: widget.salonId,
                        services: widget.services,
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
