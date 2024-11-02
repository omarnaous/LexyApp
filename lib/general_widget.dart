import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String title, String message,
    {bool isError = false}) {
  // Determine the background color based on the message type
  Color backgroundColor = isError ? Colors.deepPurple : Colors.black;

  // Show the SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure that the SnackBar size is minimal
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
              height: 4), // Add some spacing between title and message
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
      duration:
          const Duration(seconds: 3), // SnackBar will be shown for 3 seconds
    ),
  );
}

void showCustomModalBottomSheet(
  BuildContext context,
  Widget content,
  Function onClose, {
  String? title,
  bool showBackButton = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allow the bottom sheet to have custom height
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height *
            0.75, // Set height to 85% of screen height
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display a title if provided
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    showBackButton ? Icons.arrow_back_ios : Icons.close,
                    size: 30,
                  ),
                  onPressed: () {
                    onClose(); // Call the onClose function passed in
                  },
                ),
              ),
              Expanded(
                child: content, // Use the passed content widget here
              ),
            ],
          ),
        ),
      );
    },
  );
}
