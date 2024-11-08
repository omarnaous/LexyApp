import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_details.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.widget,
  });

  final SalonDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            // Using ListTile to structure the services section
            ListTile(
              title: Text(
                'Services',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
              ),
              subtitle: Text(
                '${widget.salon.services.length} Services Available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      fontSize: 14,
                    ),
              ),
              trailing: TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.deepPurple, // You can change the color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  )),
              onTap: () {
                // Navigate to the full services list or show more details
              },
            ),
          ],
        ),
      ),
    );
  }
}
