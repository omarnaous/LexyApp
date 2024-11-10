import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final List<String> _timings = List.generate(
    12,
    (index) {
      final hour = 10 + index;
      final period = hour < 12 ? 'AM' : 'PM';
      final formattedHour = hour > 12 ? hour - 12 : hour;
      return '$formattedHour:00 $period';
    },
  );

  int? _selectedTimeIndex;
  DateTime _selectedDate = DateTime.now();

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
      // Toggle selection
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
    });
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
            // Month name display
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
            // Horizontal calendar list view
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
            const SizedBox(height: 16),
            ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent double scrolling
              shrinkWrap:
                  true, // Allows ListView to be inside another ListView/Column
              itemCount: _timings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      _timings[index],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _selectedTimeIndex == index
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    tileColor: _selectedTimeIndex == index
                        ? Colors.deepPurple[500]
                        : Colors.deepPurple[50], // Selected time is deep purple
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
      bottomNavigationBar: (_selectedTimeIndex != null)
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // // Perform an action, e.g., proceed to checkout or booking confirmation
                  // print(
                  //     "Selected Date: ${DateFormat('yMMMd').format(_selectedDate)}");
                  // print("Selected Time: ${_timings[_selectedTimeIndex!]}");
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
