import 'package:flutter/material.dart';

Step reusableStep({
  required String title,
  required Widget content,
  required bool isActive,
}) {
  return Step(
    title: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    content: content,
    isActive: isActive,
  );
}
