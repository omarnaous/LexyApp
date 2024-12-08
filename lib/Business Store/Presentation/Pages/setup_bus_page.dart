import 'package:flutter/material.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/custom_textfield.dart';

class SetupBusinessPage extends StatefulWidget {
  const SetupBusinessPage({super.key});

  @override
  State<SetupBusinessPage> createState() => _SetupBusinessPageState();
}

class _SetupBusinessPageState extends State<SetupBusinessPage> {
  final List<Map<String, dynamic>> steps = [
    {"title": "Salon Images", "widget": SalonImagesPage()},
    {"title": "Salon Location", "widget": SalonLocationPage()},
    {"title": "Salon Category", "widget": SalonCategoryPage()},
    {"title": "Team Members", "widget": TeamMembersPage()},
    {"title": "Services", "widget": ServicesPage()},
  ];

  final TextEditingController salonNameController = TextEditingController();
  final TextEditingController salonDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setup Business',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salon Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: salonNameController,
              labelText: 'Enter Salon Name',
            ),
            const SizedBox(height: 16),
            const Text(
              'Salon Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: salonDescriptionController,
              labelText: 'Enter Salon Description',
              maxLines: 6, // Bigger text box for description
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        steps[index]["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.deepPurple),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => steps[index]["widget"],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalonLocationPage extends StatelessWidget {
  const SalonLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Location'),
      ),
      body: const Center(child: Text('Salon Location Page')),
    );
  }
}

class SalonCategoryPage extends StatelessWidget {
  const SalonCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Category'),
      ),
      body: const Center(child: Text('Salon Category Page')),
    );
  }
}

class TeamMembersPage extends StatelessWidget {
  const TeamMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
      ),
      body: const Center(child: Text('Team Members Page')),
    );
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: const Center(child: Text('Services Page')),
    );
  }
}
