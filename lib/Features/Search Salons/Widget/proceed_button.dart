import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/booking_page.dart';

class ProceedButton extends StatelessWidget {
  const ProceedButton({
    super.key,
    required DateTime combinedDateTime,
    required Team? selectedTeam,
    required this.widget,
  })  : _combinedDateTime = combinedDateTime,
        _selectedTeam = selectedTeam;

  final DateTime _combinedDateTime;
  final Team? _selectedTeam;
  final BookingPage widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
