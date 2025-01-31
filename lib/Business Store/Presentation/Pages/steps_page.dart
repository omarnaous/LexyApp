// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:introduction_screen/introduction_screen.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/categories_page.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/location_search.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/opening_hrs_page.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/services_page.dart';
// import 'package:lexyapp/Business%20Store/Presentation/Pages/teeam_members.dart';
// import 'package:lexyapp/custom_textfield.dart';

// class IntroScreenPage extends StatefulWidget {
//   const IntroScreenPage({super.key});

//   @override
//   State<IntroScreenPage> createState() => _IntroScreenPageState();
// }

// class _IntroScreenPageState extends State<IntroScreenPage> {
//   final List<Map<String, dynamic>> steps = [
//     {"title": "Salon Images", "widget": const SalonImagesPage()},
//     {"title": "Salon Location", "widget": const LocationSearchPage()},
//     {"title": "Salon Category", "widget": const SalonCategoryPage()},
//     {"title": "Team Members", "widget": const TeamMembersPage()},
//     {"title": "Services", "widget": const AddServicesPage()},
//   ];

//   final TextEditingController salonNameController = TextEditingController();
//   final TextEditingController salonDescriptionController =
//       TextEditingController();

//   String? userId;
//   List<String> selectedDays = [];
//   TimeOfDay? openingTime;
//   TimeOfDay? closingTime;

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser?.uid;
//   }

//   Future<void> _updateSalonData(String field, dynamic value) async {
//     if (userId == null) return;

//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('Salons')
//           .where('ownerUid', isEqualTo: userId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final salonDoc = querySnapshot.docs.first;
//         await salonDoc.reference.update({field: value});
//         debugPrint('$field updated successfully.');
//       }
//     } catch (e) {
//       debugPrint('Error updating $field: $e');
//     }
//   }

//   void _toggleDaySelection(String day) {
//     setState(() {
//       if (selectedDays.contains(day)) {
//         selectedDays.remove(day);
//       } else {
//         selectedDays.add(day);
//       }
//     });
//     _updateSalonData('workingDays', selectedDays);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (userId == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text('User not logged in.'),
//         ),
//       );
//     }

//     final List<PageViewModel> pageviewModels = [
//       PageViewModel(
//         title: "Working Days",
//         bodyWidget: Wrap(
//           spacing: 8.0,
//           children: [
//             for (var day in [
//               'Monday',
//               'Tuesday',
//               'Wednesday',
//               'Thursday',
//               'Friday',
//               'Saturday',
//               'Sunday'
//             ])
//               ChoiceChip(
//                 label: Text(day),
//                 selected: selectedDays.contains(day),
//                 onSelected: (selected) => _toggleDaySelection(day),
//               ),
//           ],
//         ),
//       ),
//       PageViewModel(
//         title: "Working Hours",
//         bodyWidget: Card(
//           margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//           child: ListTile(
//             title: const Text(
//               'Working hours',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             trailing:
//                 const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SelectWorkingHoursPage(
//                     selectedDays: selectedDays,
//                     userId: userId ?? '',
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       PageViewModel(
//         title: "Salon Images",
//         bodyWidget: const SalonImagesPage(),
//       ),
//       PageViewModel(
//         title: "Salon Location",
//         bodyWidget: const LocationSearchPage(),
//       ),
//       PageViewModel(
//         title: "Salon Category",
//         bodyWidget: const SalonCategoryPage(),
//       ),
//       PageViewModel(
//         title: "Team Members",
//         bodyWidget: const TeamMembersPage(),
//       ),
//       PageViewModel(
//         title: "Services",
//         bodyWidget: const AddServicesPage(),
//       ),
//       PageViewModel(
//         title: "Salon Name",
//         bodyWidget: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: CustomTextField(
//             controller: salonNameController,
//             labelText: 'Enter Salon Name',
//             onSubmitted: (value) => _updateSalonData('name', value),
//           ),
//         ),
//       ),
//       PageViewModel(
//         title: "Salon Description",
//         bodyWidget: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: CustomTextField(
//             controller: salonDescriptionController,
//             labelText: 'Enter Salon Description',
//             maxLines: null,
//             onSubmitted: (value) => _updateSalonData('about', value),
//           ),
//         ),
//       ),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Setup Business'),
//       ),
//       body: IntroductionScreen(
//         pages: pageviewModels,
//         showNextButton: true,
//         next: const Text("Next"),
//         done: const Text("Done"),
//         onDone: () {
//           debugPrint('Setup completed!');
//           debugPrint('Salon Name: ${salonNameController.text}');
//           debugPrint('Salon Description: ${salonDescriptionController.text}');
//           debugPrint('Working Days: $selectedDays');
//         },
//       ),
//     );
//   }
// }
