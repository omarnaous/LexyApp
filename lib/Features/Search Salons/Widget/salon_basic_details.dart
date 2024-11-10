import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';

class SalonBasicDetails extends StatelessWidget {
  const SalonBasicDetails({
    super.key,
    required this.widget,
    required this.todayHours,
  });

  final SalonDetailsPage widget;
  final String todayHours;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Text(
              widget.salon.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
            ),
            const SizedBox(height: 5), // Uniform spacing

            Text(
              widget.salon.city,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 5), // Uniform spacing
            Text(
              'Open Today from $todayHours',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
