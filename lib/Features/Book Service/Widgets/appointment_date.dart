import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDateCheckOut extends StatelessWidget {
  final DateTime date;

  const AppointmentDateCheckOut({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEE, d MMM yyyy').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                DateFormat('hh:mm a').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
