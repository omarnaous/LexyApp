import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/categories_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/location_search.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/opening_hrs_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/services_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/teeam_members.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:phone_form_field/phone_form_field.dart';

class SetupBusinessPage extends StatefulWidget {
  const SetupBusinessPage({super.key, this.userId, this.isAdmin});
  final String? userId;
  final bool? isAdmin;

  @override
  State<SetupBusinessPage> createState() => _SetupBusinessPageState();
}

class _SetupBusinessPageState extends State<SetupBusinessPage> {
  final TextEditingController salonNameController = TextEditingController();
  final TextEditingController salonDescriptionController =
      TextEditingController();

  String? userId;
  List<String> selectedDays = [];
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _updateSalonData(String field, dynamic value) async {
    if (userId == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Salons')
              .where('ownerUid', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({field: value});
        debugPrint('$field updated successfully.');
        // showCustomSnackBar(context, 'Updated Successfully!', '');
      }
    } catch (e) {
      debugPrint('Error updating $field: $e');
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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {"title": "6 - Salon Images", "widget": const SalonImagesPage()},
      {"title": "7 - Salon Location", "widget": const LocationSearchPage()},
      {"title": "8 - Team Members", "widget": const TeamMembersPage()},
      {"title": "9 - Salon Category", "widget": const SalonCategoryPage()},
      {
        "title": "10 - Services",
        "widget": AddServicesPage(salonId: widget.userId ?? ''),
      },
    ];
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in.')));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          actions: [],
          leading: Container(),
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
                  .where('ownerUid', isEqualTo: userId)
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
                                        userId: userId ?? '',
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomTextField(
                      controller: salonNameController,
                      labelText: 'Enter Salon Name',
                      onSubmitted: (value) => _updateSalonData('name', value),
                      onChanged: (value) => _updateSalonData('name', value),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '4 - Salon Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: EdgeInsets.all(16.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           '5 - Phone Number',
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         Switch(
                //           value:
                //               salonModel.showPhoneNumber ??
                //               false, // Assuming you have salonModel
                //           onChanged: (value) {
                //             _updateSalonData('showPhoneNumber', value);
                //           },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // salonModel.showPhoneNumber == true
                //     ? SliverToBoxAdapter(
                //       child: PhoneNumberInput(
                //         initialData: salonModel.phoneNumber,
                //         onChanged: (phoneData) {
                //           _updateSalonData('phoneNumber', phoneData);
                //         },
                //         onEmpty: (show) {
                //           _updateSalonData('showPhoneNumber', show);
                //         },
                //       ),
                //     )
                //     : SliverToBoxAdapter(),
                // salonModel.showPhoneNumber == true
                //     ? const SliverToBoxAdapter(child: SizedBox(height: 10))
                //     : SliverToBoxAdapter(),
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
                                      salonId: widget.userId ?? '',
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class PhoneNumberInput extends StatelessWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onChanged;
  final Function(bool) onEmpty;

  const PhoneNumberInput({
    Key? key,
    required this.initialData,
    required this.onChanged,
    required this.onEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PhoneFormField(
        validator: (value) {
          if (value?.nsn == '') {
            print("empty");
            onEmpty(false);
            return 'Fill Out Phone Number or Number will not be shown in the main page';
          }
          return null;
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
          onChanged({
            'nsn': phoneNumber.nsn,
            'isoCode': phoneNumber.isoCode.index,
            'countryCode': phoneNumber.countryCode,
          });
        },
        initialValue: PhoneNumber(
          isoCode: IsoCode.values[initialData?['isoCode'] ?? IsoCode.LB.index],
          nsn: initialData?['nsn'] ?? '',
        ),
      ),
    );
  }
}
