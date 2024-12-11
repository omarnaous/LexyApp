import 'package:flutter/material.dart';

class PaymentMethodSelection extends StatelessWidget {
  final String selectedPaymentMethod;
  final ValueChanged<String?> onChanged;

  const PaymentMethodSelection(
      {super.key,
      required this.selectedPaymentMethod,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment method',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          RadioListTile(
            contentPadding: EdgeInsets.all(0),
            value: 'Pay at venue',
            groupValue: selectedPaymentMethod,
            onChanged: onChanged,
            title: const Text('Pay at venue',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Cash'),
          ),
        ],
      ),
    );
  }
}
