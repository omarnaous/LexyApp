import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class ScheduleBusinessPage extends StatefulWidget {
  const ScheduleBusinessPage({super.key});

  @override
  State<ScheduleBusinessPage> createState() => _ScheduleBusinessPageState();
}

class _ScheduleBusinessPageState extends State<ScheduleBusinessPage> {
  CalendarView _calendarView = CalendarView.day; // Default calendar view
  DateTime _selectedDate = DateTime.now(); // Selected Date for Weekly Calendar

  bool _isWeeklyCalendarVisible = false; // Toggle for weekly calendar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Calendar"),
        actions: [
          // Dropdown to switch views
          DropdownButton<CalendarView>(
            value: _calendarView,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(
                value: CalendarView.day,
                child: Text("Day View"),
              ),
              DropdownMenuItem(
                value: CalendarView.week,
                child: Text("Week View"),
              ),
              DropdownMenuItem(
                value: CalendarView.month,
                child: Text("Month View"),
              ),
              DropdownMenuItem(
                value: CalendarView.timelineWeek,
                child: Text("Weekly Calendar"),
              ),
            ],
            onChanged: (view) {
              setState(() {
                _calendarView = view!;
                _isWeeklyCalendarVisible = view == CalendarView.timelineWeek;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekly Calendar (only visible if selected)
          if (_isWeeklyCalendarVisible)
            CustomWeeklyCalendar(
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          Expanded(
            child: SfCalendar(
              view: _calendarView == CalendarView.timelineWeek
                  ? CalendarView.week
                  : _calendarView,
              initialDisplayDate: _selectedDate,
              todayHighlightColor: Colors.deepPurple,
              dataSource: _getDummyAppointments(),
              appointmentTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dummy Appointments for Display
  AppointmentDataSource _getDummyAppointments() {
    return AppointmentDataSource([
      Appointment(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        subject: 'Business Meeting',
        color: Colors.blue,
      ),
      Appointment(
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        subject: 'Client Call',
        color: Colors.green,
      ),
    ]);
  }
}

/// Weekly Calendar Widget
class CustomWeeklyCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CustomWeeklyCalendar({super.key, required this.onDateSelected});

  @override
  State<CustomWeeklyCalendar> createState() => _CustomWeeklyCalendarState();
}

class _CustomWeeklyCalendarState extends State<CustomWeeklyCalendar> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> _getDaysInWeek() {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = _getDaysInWeek();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: daysOfWeek.map((day) {
              final isSelected = _selectedDate.day == day.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                  widget.onDateSelected(day);
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.deepPurple : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.grey,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE').format(day),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// DataSource for Appointments
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
