import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class TeamMembersList extends StatefulWidget {
  final Salon salon;

  const TeamMembersList({
    Key? key,
    required this.salon,
  }) : super(key: key);

  @override
  State<TeamMembersList> createState() => _TeamMembersListState();
}

class _TeamMembersListState extends State<TeamMembersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.salon.team.length,
        itemBuilder: (context, index) {
          final teamMember = widget.salon.team[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(teamMember.imageLink),
                backgroundColor: Colors.deepPurple[100],
                radius: 20,
              ),
              title: Text(
                teamMember.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
