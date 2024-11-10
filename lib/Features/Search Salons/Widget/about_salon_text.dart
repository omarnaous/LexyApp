import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';

class AboutSalonText extends StatelessWidget {
  const AboutSalonText({
    super.key,
    required this.widget,
  });

  final SalonDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.salon.about,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
