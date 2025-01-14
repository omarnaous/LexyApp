// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // For clipboard functionality

import 'package:lexyapp/Features/Authentication/Data/user_model.dart';

class ClientInformationPage extends StatefulWidget {
  const ClientInformationPage({
    super.key,
    required this.userModel,
  });
  final UserModel userModel;

  @override
  State<ClientInformationPage> createState() => _ClientInformationPageState();
}

class _ClientInformationPageState extends State<ClientInformationPage> {
  void _callClient(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make a call.')),
      );
    }
  }

  void _whatsappClient(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Information'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Increased margin for more spacing
                  child: ListTile(
                    title: const Text(
                      'First Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.firstName),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(user.firstName),
                    ),
                  ),
                ),
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Increased margin for more spacing
                  child: ListTile(
                    title: const Text(
                      'Last Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.lastName ?? 'Not provided'),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () =>
                          _copyToClipboard(user.lastName ?? 'Not provided'),
                    ),
                  ),
                ),
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Increased margin for more spacing
                  child: ListTile(
                    title: const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(user.email),
                    ),
                  ),
                ),
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Increased margin for more spacing
                  child: ListTile(
                    title: const Text(
                      'Phone Number',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.phoneNumber),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(user.phoneNumber),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callClient(user.phoneNumber),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _whatsappClient(user.phoneNumber),
                    icon: const Icon(FontAwesomeIcons.whatsapp),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
