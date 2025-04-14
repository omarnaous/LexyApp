import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart'; // Import Firestore

class SelectWorkingHoursPage extends StatefulWidget {
  final List<String> selectedDays; // This will receive a list of selected days
  final String userId; // Now passing userId to query by ownerUid

  const SelectWorkingHoursPage({
    Key? key,
    required this.selectedDays,
    required this.userId,
  }) : super(key: key);

  @override
  _SelectWorkingHoursPageState createState() => _SelectWorkingHoursPageState();
}

class _SelectWorkingHoursPageState extends State<SelectWorkingHoursPage> {
  Map<String, TimeRange> workingHours = {
    'Monday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Tuesday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Wednesday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Thursday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Friday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Saturday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
    'Sunday': TimeRange(
      opening: const TimeOfDay(hour: 9, minute: 0),
      closing: const TimeOfDay(hour: 20, minute: 0),
    ),
  };

  // List of days in the correct order
  final List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Method to sort the selected days in the correct order
  List<String> getSortedDays(List<String> selectedDays) {
    return selectedDays
        .where((day) => allDays.contains(day)) // Ensure it's a valid day
        .toList()
      ..sort((a, b) => allDays.indexOf(a).compareTo(allDays.indexOf(b)));
  }

  // Method to parse a time string like "9:00 AM" to TimeOfDay
  TimeOfDay _parseTime(String time) {
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (timeParts[1].toLowerCase() == 'pm' && hour != 12) {
      hour += 12; // Convert PM times to 24-hour format
    } else if (timeParts[1].toLowerCase() == 'am' && hour == 12) {
      hour = 0; // Handle 12 AM as 00:00
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Select time function for opening or closing hours
  Future<void> _selectTime(
    BuildContext context,
    String day,
    bool isOpening,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isOpening
              ? const TimeOfDay(hour: 9, minute: 0)
              : const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: false), // Forces 12-hour format
          child: Localizations.override(
            context: context,
            locale: const Locale('en', 'US'),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      final roundedTime = _roundToNearestQuarter(picked);

      setState(() {
        if (isOpening) {
          workingHours[day]?.opening = roundedTime;
        } else {
          workingHours[day]?.closing = roundedTime;
        }
      });
    }
  }

  TimeOfDay _roundToNearestQuarter(TimeOfDay time) {
    int minute = time.minute;
    int newMinute = (minute / 15).round() * 15;

    if (newMinute == 60) {
      newMinute = 0;
      int newHour = (time.hour + 1) % 24; // Wrap around after 23:59
      return TimeOfDay(hour: newHour, minute: newMinute);
    }

    return TimeOfDay(hour: time.hour, minute: newMinute);
  }

  // Fetch salon data once and set the working hours from Firestore
  Future<void> _fetchSalonData(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot =
          await firestore
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonData = querySnapshot.docs.first.data();
        final workingHoursData = salonData['workingHours'] ?? {};

        setState(() {
          workingHours = allDays.asMap().map((index, day) {
            if (workingHoursData.containsKey(day)) {
              var openingTime = workingHoursData[day]['opening'];
              var closingTime = workingHoursData[day]['closing'];
              return MapEntry(
                day,
                TimeRange(
                  opening: _parseTime(openingTime),
                  closing: _parseTime(closingTime),
                ),
              );
            } else {
              return MapEntry(
                day,
                TimeRange(
                  opening: const TimeOfDay(hour: 9, minute: 0),
                  closing: const TimeOfDay(hour: 20, minute: 0),
                ),
              );
            }
          });
        });
      }
    } catch (e) {
      print('Error fetching salon data: $e');
    }
  }

  // Update Firestore with the working hours data
  Future<void> _updateSalonWorkingHours(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot =
          await firestore
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        Map<String, dynamic> workingHoursData = {};
        workingHours.forEach((day, timeRange) {
          workingHoursData[day] = {
            'opening': timeRange.opening?.format(context),
            'closing': timeRange.closing?.format(context),
          };
        });

        // Update the salon's document with the working hours
        await doc.reference.update({'workingHours': workingHoursData});

        showCustomSnackBar(context, 'Saved', 'Working Hours Updated!');

        print('Salon working hours updated successfully!');
      } else {
        print('No salon found with the given ownerUid');
      }
    } catch (e) {
      print('Error updating working hours: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSalonData(widget.userId); // Fetch the data when the page opens
  }

  @override
  Widget build(BuildContext context) {
    // Sort the selected days before displaying them
    List<String> sortedDays = getSortedDays(widget.selectedDays);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Working Hours'),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children:
                  sortedDays.map((day) {
                    final timeRange = workingHours[day]!;
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeRange.opening != null
                                      ? 'Opening: ${timeRange.opening!.format(context)}'
                                      : 'Opening: Not set',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  timeRange.closing != null
                                      ? 'Closing: ${timeRange.closing!.format(context)}'
                                      : 'Closing: Not set',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Row of Edit buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _selectTime(context, day, true),
                                    label: const Text(
                                      'Edit Opening',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ), // Space between buttons
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _selectTime(context, day, false),
                                    label: const Text(
                                      'Edit Closing',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Always show the Save Working Hours button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Implement save functionality
                _updateSalonWorkingHours(
                  widget.userId,
                ); // Save the updated working hours
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Button takes full width
              ),
              child: const Text(
                'Save Working Hours',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeRange {
  TimeOfDay? opening;
  TimeOfDay? closing;

  TimeRange({this.opening, this.closing});
}
