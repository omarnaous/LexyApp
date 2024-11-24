import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateCircleCalendar extends StatelessWidget {
  const DateCircleCalendar({
    super.key,
    required this.isSelected,
    required this.date,
  });

  final bool isSelected;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(date),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
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
    );
  }
}
