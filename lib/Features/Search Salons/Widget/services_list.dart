import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';

class ServicesList extends StatelessWidget {
  const ServicesList({super.key, required this.widget});

  final SalonDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = widget.salon.services[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            service.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'USD ${service.price}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        // Limit the number of services to 4
        childCount:
            widget.salon.services.length > 3 ? 3 : widget.salon.services.length,
      ),
    );
  }
}
