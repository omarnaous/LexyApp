import 'package:flutter/material.dart';

class EmptyListWarning extends StatelessWidget {
  const EmptyListWarning({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
