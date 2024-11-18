// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class AppointmentDateCheckOut extends StatelessWidget {
  final DateTime date;
  final Team teamMember;

  const AppointmentDateCheckOut({
    super.key,
    required this.date,
    required this.teamMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Team Member Image or Default Icon
              if (teamMember.imageLink.isEmpty)
                Container()
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: NetworkImage(teamMember.imageLink),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              // Team Member Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Member Name
                    Text(
                      teamMember.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          "${DateFormat('EEE, d MMM yyyy').format(date)} - ",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(date),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
