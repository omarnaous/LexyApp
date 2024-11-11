import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  final double subtotal;
  final double total;
  final String selectedPaymentMethod;
  final VoidCallback onSaveAppointment;

  const ConfirmButton({
    super.key,
    required this.subtotal,
    required this.total,
    required this.selectedPaymentMethod,
    required this.onSaveAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onPressed: () async {
          // Execute the onSaveAppointment callback
          onSaveAppointment();

          if (kDebugMode) {
            print('Booking Confirmed:');
            print('Subtotal: JOD ${subtotal.toStringAsFixed(2)}');
            print('Total: JOD ${total.toStringAsFixed(2)}');
            print('Payment Method: $selectedPaymentMethod');
          }
        },
        child: const Text(
          'Confirm Appointment',
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
