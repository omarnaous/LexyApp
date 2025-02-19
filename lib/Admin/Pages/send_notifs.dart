import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  // Function to send notification to all users
  Future<void> sendNotification(String title, String body) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('sendNotificationToAllUsers');
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'topic': 'users',
      });
      print('Notification sent: ${response.data}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification to All Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Notification to All Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: 'Notification Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Notification Body'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String title = titleController.text;
                final String body = bodyController.text;
                if (title.isNotEmpty && body.isNotEmpty) {
                  sendNotification(title, body);
                }
              },
              child: const Text('Send to All'),
            ),
          ],
        ),
      ),
    );
  }
}
