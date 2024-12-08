import 'package:flutter/material.dart';

void showCustomDialog({
  required BuildContext context,
  required String title,
  required List<Widget> contentFields,
  required VoidCallback onSubmit,
  double? dialogWidth, // Optional dialog width
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: dialogWidth ?? MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: contentFields,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
