import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/categories_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/location_search.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/opening_hrs_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/services_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/teeam_members.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AdminSalonEdit extends StatefulWidget {
  const AdminSalonEdit({super.key, required this.ownerUId});
  final String ownerUId;

  @override
  State<AdminSalonEdit> createState() => _AdminSalonEditState();
}

class _AdminSalonEditState extends State<AdminSalonEdit> {
  final TextEditingController salonNameController = TextEditingController();
  final TextEditingController salonDescriptionController =
      TextEditingController();

  // String? userId;
  List<String> selectedDays = [];
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  @override
  void initState() {
    super.initState();
    // userId = FirebaseAuth.instance.currentUser?.uid;
  }

  // Method to toggle salon status (active / inactive)
  Future<void> _toggleSalonStatus(bool currentStatus) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: widget.ownerUId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({'active': !currentStatus});
        debugPrint('Salon status updated successfully.');
      }
    } catch (e) {
      debugPrint('Error updating salon status: $e');
    }
  }

  void _toggleDaySelection(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
    _updateSalonData('workingDays', selectedDays);
  }

  Future<void> _updateSalonData(String field, dynamic value) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: widget.ownerUId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({field: value});
        debugPrint('$field updated successfully.');
        // ignore: use_build_context_synchronously
      }
    } catch (e) {
      debugPrint('Error updating $field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        "title": "6 - Salon Images",
        "widget": SalonImagesPage(isAdmin: true, salonId: widget.ownerUId),
      },
      {
        "title": "7 - Salon Location",
        "widget": LocationSearchPage(isAdmin: true, owneruid: widget.ownerUId),
      },
      {
        "title": "8 - Team Members",
        "widget": TeamMembersPage(isAdmin: true, salonId: widget.ownerUId),
      },
      {
        "title": "9 - Salon Category",
        "widget": SalonCategoryPage(isAdmin: true, salonId: widget.ownerUId),
      },
      {
        "title": "10 - Services",
        "widget": AddServicesPage(salonId: widget.ownerUId),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setup Business',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Salons')
                .where('ownerUid', isEqualTo: widget.ownerUId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No salon data found.'));
          }

          final salonDoc = snapshot.data!.docs.first;
          final salonData = salonDoc.data() as Map<String, dynamic>;

          salonNameController.text = salonData['name'] ?? '';
          salonDescriptionController.text = salonData['about'] ?? '';
          selectedDays = List<String>.from(salonData['workingDays'] ?? []);

          // Handle Timestamp for openingTime and closingTime
          final openingTimestamp = salonData['openingTime'] as Timestamp?;
          final closingTimestamp = salonData['closingTime'] as Timestamp?;
          openingTime =
              openingTimestamp != null
                  ? TimeOfDay(
                    hour: openingTimestamp.toDate().hour,
                    minute: openingTimestamp.toDate().minute,
                  )
                  : null;
          closingTime =
              closingTimestamp != null
                  ? TimeOfDay(
                    hour: closingTimestamp.toDate().hour,
                    minute: closingTimestamp.toDate().minute,
                  )
                  : null;

          final bool isActive = salonData['active'] ?? false;

          Salon salonModel = Salon.fromMap(salonData);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1 - Salon Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isActive ? 'Active' : 'Not Active',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isActive ? Icons.toggle_off : Icons.toggle_on,
                              color: isActive ? Colors.green : Colors.red,
                              size: 40,
                            ),
                            onPressed: () => _toggleSalonStatus(isActive),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Allow Bookings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value:
                                  salonModel.showBooknow ??
                                  false, // Assuming you have salonModel
                              onChanged: (value) {
                                _updateSalonData('showBooknow', value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '2 - Working Days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          for (var day in [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday',
                          ])
                            ChoiceChip(
                              label: Text(day),
                              selected: selectedDays.contains(day),
                              onSelected:
                                  (selected) => _toggleDaySelection(day),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 0.0,
                          horizontal: 0.0,
                        ),
                        child: ListTile(
                          title: const Text(
                            'Working hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.deepPurple,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SelectWorkingHoursPage(
                                      selectedDays: selectedDays,
                                      userId: widget.ownerUId,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '3 - Salon Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomTextField(
                    controller: salonNameController,
                    labelText: 'Enter Salon Name',
                    onChanged: (value) => _updateSalonData('name', value),
                    onSubmitted: (value) => _updateSalonData('name', value),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '4 - Salon Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomTextField(
                    controller: salonDescriptionController,
                    labelText: 'Enter Salon Description',
                    maxLines: null,
                    onSubmitted: (value) => _updateSalonData('about', value),
                    onChanged: (value) => _updateSalonData('about', value),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5 - Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value:
                            salonModel.showPhoneNumber ??
                            false, // Assuming you have salonModel
                        onChanged: (value) {
                          _updateSalonData('showPhoneNumber', value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              salonModel.showPhoneNumber == true
                  ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PhoneFormField(
                        validator: (value) {
                          if (value?.nsn == '') {
                            _updateSalonData('showPhoneNumber', false);
                            return 'Fill Out Phone Number or Number will not be shown in the main page';
                          }
                          return null; // Validation passed
                        },
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onChanged: (phoneNumber) {
                          _updateSalonData('phoneNumber', {
                            'nsn': phoneNumber.nsn,
                            'isoCode': phoneNumber.isoCode.index,
                            'countryCode': phoneNumber.countryCode,
                          });
                        },
                        initialValue: PhoneNumber(
                          isoCode:
                              IsoCode.values[salonModel
                                  .phoneNumber?["isoCode"]],
                          nsn: salonModel.phoneNumber?["nsn"] ?? '',
                        ),
                      ),
                    ),
                  )
                  : SliverToBoxAdapter(),
              salonModel.showPhoneNumber == true
                  ? const SliverToBoxAdapter(child: SizedBox(height: 10))
                  : SliverToBoxAdapter(),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final step = steps[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    child: ListTile(
                      title: Text(
                        step["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.deepPurple,
                      ),
                      onTap: () {
                        if (index == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddServicesPage(
                                    salonModel: salonModel,
                                    salonId: widget.ownerUId,
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => step["widget"],
                            ),
                          );
                        }
                      },
                    ),
                  );
                }, childCount: steps.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ],
          );
        },
      ),
    );
  }
}
