import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.formattedDateTime,
    required this.status,
  });

  final AppointmentModel appointment;
  final String formattedDateTime;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Appointment Info in a Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.salonModel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formattedDateTime,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "From ${appointment.startTime} till ${appointment.endTime}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      appointment.status,
                      style: TextStyle(
                        color: _getStatusColor(appointment.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Forward Icon as a trailing button
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to define status color dynamically
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
