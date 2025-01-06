import 'package:flutter/material.dart';

class TimeListTile extends StatelessWidget {
  const TimeListTile({
    super.key,
    required List<String> filteredTimings,
    required int? selectedTimeIndex,
    required this.index,
    required this.onTap,
    required this.isTaken,
    this.additionalInfo = '',
  })  : _filteredTimings = filteredTimings,
        _selectedTimeIndex = selectedTimeIndex;

  final List<String> _filteredTimings;
  final int? _selectedTimeIndex;
  final int index;
  final bool isTaken; // Indicates if the appointment is not available
  final Function onTap;
  final String additionalInfo; // Information about unavailable members

  @override
  Widget build(BuildContext context) {
    if (additionalInfo == 'Not available') {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          _filteredTimings[index],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _selectedTimeIndex == index
                    ? Colors.white // White text for selected slot
                    : Colors.black87, // Black text for available slots
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          isTaken
              ? "${additionalInfo.isNotEmpty ? '$additionalInfo is not available at this time' : 'Not Available'}"
              : "Available",
          style: TextStyle(
            color: _selectedTimeIndex == index
                ? Colors.white // Deep purple for selected slot
                : isTaken
                    ? Colors.deepPurple // Red for unavailable slots
                    : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        tileColor: isTaken
            ? Colors.deepPurple[100] // Light purple for unavailable slots
            : _selectedTimeIndex == index
                ? Colors.deepPurple[500] // Deep purple for selected slot
                : Colors.deepPurple[50], // Light purple for available slots
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: isTaken
            ? null // Disable tap for unavailable slots
            : () {
                onTap(); // Call the tap function for available slots
              },
      ),
    );
  }
}
