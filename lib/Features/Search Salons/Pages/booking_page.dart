// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';

import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

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
  final List<String> _allTimings = List.generate(
    12,
    (index) {
      final hour = 10 + index;
      final period = hour < 12 ? 'AM' : 'PM';
      final formattedHour = hour > 12 ? hour - 12 : hour;
      return '$formattedHour:00 $period';
    },
  );

  List<String> get _filteredTimings {
    if (!_isToday) return _allTimings;

    final now = DateTime.now();
    final currentHour = now.hour;
    return _allTimings.where((timing) {
      final hour = _getHourFromTiming(timing);
      return hour > currentHour;
    }).toList();
  }

  bool get _isToday =>
      _selectedDate.day == DateTime.now().day &&
      _selectedDate.month == DateTime.now().month &&
      _selectedDate.year == DateTime.now().year;

  int _getHourFromTiming(String timing) {
    final parts = timing.split(' ');
    final hourPart = int.parse(parts[0].split(':')[0]);
    final period = parts[1];

    int hour = hourPart;
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour;
  }

  String? _selectedTeamMember; // Use the team member's name as the identifier
  int? _selectedTimeIndex;
  DateTime _selectedDate = DateTime.now();

  List<Team> get _teamMembersWithAnyone {
    return [
      Team(
        name: "Anyone",
        imageLink: "", // No image for "Anyone"
      ),
      ...widget.teamMembers,
    ];
  }

  List<DateTime> get _daysInMonth {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(const Duration(days: 30));
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  void _selectTime(int index) {
    setState(() {
      if (_selectedTimeIndex == index) {
        _selectedTimeIndex = null;
      } else {
        _selectedTimeIndex = index;
      }
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeIndex = null; // Reset time selection when date changes
    });
  }

  void _selectTeamMember(String memberName) {
    setState(() {
      _selectedTeamMember = memberName;
    });
  }

  Team? get _selectedTeam {
    return _teamMembersWithAnyone
        .firstWhere((team) => team.name == _selectedTeamMember, orElse: null);
  }

  DateTime get _combinedDateTime {
    if (_selectedTimeIndex == null) return _selectedDate;

    final timeString = _filteredTimings[_selectedTimeIndex!];
    final timeParts = timeString.split(' ');
    final period = timeParts[1];
    int hour = int.parse(timeParts[0].split(':')[0]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _daysInMonth.length,
                  itemBuilder: (context, index) {
                    final date = _daysInMonth[index];
                    bool isSelected = _selectedDate.day == date.day &&
                        _selectedDate.month == date.month &&
                        _selectedDate.year == date.year;

                    return GestureDetector(
                      onTap: () {
                        _selectDate(date);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  DateFormat('d').format(date),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('E').format(date).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedTeamMember,
                decoration: InputDecoration(
                  labelText: "Select Team Member",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: _teamMembersWithAnyone.map((member) {
                  return DropdownMenuItem<String>(
                    value: member.name,
                    child: Row(
                      children: [
                        if (member.name == "Anyone")
                          const Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                          )
                        else if (member.imageLink.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(member.imageLink),
                              radius: 15,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(member.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectTeamMember(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _filteredTimings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      _filteredTimings[index],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _selectedTimeIndex == index
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    tileColor: _selectedTimeIndex == index
                        ? Colors.deepPurple[500]
                        : Colors.deepPurple[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      _selectTime(index);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          (_selectedTimeIndex != null && _selectedTeamMember != null)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      final combinedDateTime = _combinedDateTime;

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return CheckOutPage(
                            teamMember: _selectedTeam!,
                            salonId: widget.salonId,
                            services: widget.services,
                            date: combinedDateTime,
                          );
                        },
                      ));
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
                )
              : const SizedBox.shrink(),
    );
  }
}
