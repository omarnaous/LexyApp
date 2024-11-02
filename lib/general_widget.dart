import 'package:flutter/material.dart';

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
