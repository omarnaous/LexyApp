import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';

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
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return CheckOutPage(
                    showConfirmButton: false,
                    teamMember: appointment.salonModel.team[0],
                    date: appointment.date,
                    salonId: appointment.salonId,
                    services: appointment.services);
              },
            ));
          },
          title: Text(
            appointment.salonModel.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("$formattedDateTime\n$status"),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.deepPurple.shade400,
          ),
        ),
      ),
    );
  }
}
