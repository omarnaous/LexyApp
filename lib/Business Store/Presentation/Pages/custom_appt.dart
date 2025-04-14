// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class CustomAppointmentPage extends StatefulWidget {
  const CustomAppointmentPage({
    Key? key,
    this.selectedDate,
    this.salon,
    this.isEdit = false,
    this.appointment,
  }) : super(key: key);

  final DateTime? selectedDate;
  final Salon? salon;
  final bool isEdit;
  final AppointmentModel? appointment;

  @override
  State<CustomAppointmentPage> createState() => _CustomAppointmentPageState();
}

class _CustomAppointmentPageState extends State<CustomAppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  String? _endTime;
  int? _selectedDuration = 30;

  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _teamMemberNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<int> durationOptions = [
    15,
    30,
    45,
    60,
    75,
    90,
    105,
    120,
    135,
    150,
    165,
    180,
    195,
    210,
    225,
    240,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.appointment != null) {
      // Pre-fill fields from the appointment model in edit mode
      _selectedDate = widget.appointment!.date;
      _startTime = _parseTime(widget.appointment!.startTime);

      // Calculate duration from start and end times
      final start = _parseTime(widget.appointment!.startTime);
      final end = _parseTime(widget.appointment!.endTime);
      final durationInMinutes =
          DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                end.hour,
                end.minute,
              )
              .difference(
                DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  start.hour,
                  start.minute,
                ),
              )
              .inMinutes;
      _selectedDuration = durationInMinutes;
      _calculateEndTime();

      // Assume at least one service exists
      final service =
          widget.appointment!.services[0]['service'] as ServiceModel;
      final team = widget.appointment!.services[0]['teamMember'] as Team;

      _serviceNameController.text = service.title;
      _servicePriceController.text = service.price.toString();
      _teamMemberNameController.text = team.name;
      _descriptionController.text = service.description;
    } else {
      _selectedDate = widget.selectedDate ?? DateTime.now();
      _startTime = _alignTimeToFiveMinutes(
        TimeOfDay.fromDateTime(_selectedDate!),
      );
      _calculateEndTime();
    }
  }

  /// Helper to parse a time string (e.g., "08:30 AM") to a TimeOfDay.
  TimeOfDay _parseTime(String timeString) {
    final dateTime = DateFormat('hh:mm a').parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  String formatDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return "${hours}h ${mins}m";
    if (hours > 0) return "${hours}h";
    return "${mins}m";
  }

  TimeOfDay _alignTimeToFiveMinutes(TimeOfDay time) {
    int newMinute = (time.minute / 5).round() * 5;
    return TimeOfDay(hour: time.hour, minute: newMinute);
  }

  void _calculateEndTime() {
    if (_startTime == null ||
        _selectedDuration == null ||
        _selectedDate == null)
      return;
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = startDateTime.add(
      Duration(minutes: _selectedDuration!),
    );
    setState(() {
      _endTime = DateFormat('hh:mm a').format(endDateTime);
    });
  }

  Future<void> _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _calculateEndTime();
      });
    }
  }

  Future<void> _pickStartTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime!,
    );
    if (pickedTime != null) {
      setState(() {
        _startTime = _alignTimeToFiveMinutes(pickedTime);
        _calculateEndTime();
      });
    }
  }

  void _saveAppointmentfinal() {
    if (_serviceNameController.text.isEmpty) {
      _showSnackBar('Service Name is required');
      return;
    }
    if (_servicePriceController.text.isEmpty ||
        double.tryParse(_servicePriceController.text) == null ||
        double.parse(_servicePriceController.text) <= 0) {
      _showSnackBar('Please enter a valid price');
      return;
    }
    if (_teamMemberNameController.text.isEmpty) {
      _showSnackBar('Team Member Name is required');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      _showSnackBar('Description is required');
      return;
    }
    // If edit mode, update the existing appointment; otherwise, save a new one.
    if (widget.isEdit) {
      _updateAppointment();
    } else {
      _onSaveSuccessful();
    }
  }

  void _onSaveSuccessful() {
    _saveAppointment(
      selectedDate: _selectedDate!,
      startTime: formatTime(_startTime!),
      endTime: _endTime!,
      serviceName: _serviceNameController.text,
      servicePrice: double.parse(_servicePriceController.text),
      teamMemberName: _teamMemberNameController.text,
      description: _descriptionController.text,
    );
  }

  /// Update existing appointment in Firestore.
  Future<void> _updateAppointment() async {
    if (widget.appointment == null) {
      _showSnackBar('No appointment to update');
      return;
    }
    FirebaseFirestore.instance
        .collection('Salons')
        .where('ownerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
          if (value.docs.isEmpty) {
            _showSnackBar('No salon found for this user');
            return;
          }
          Salon salon = Salon.fromMap(value.docs.first.data());

          ServiceModel serviceModel = ServiceModel(
            title: _serviceNameController.text,
            category: 'Self Service',
            price: double.parse(_servicePriceController.text),
            description: _descriptionController.text,
            duration: _selectedDuration!,
          );

          Map<String, dynamic> updatedData = {
            'date': _selectedDate,
            'startTime': formatTime(_startTime!),
            'endTime': _endTime,
            'services': [
              {
                'service': serviceModel.toMap(),
                'teamMember':
                    Team(
                      name: _teamMemberNameController.text,
                      imageLink: '',
                    ).toMap(),
              },
            ],
            'salonModel': salon.toMap(),
          };

          await FirebaseFirestore.instance
              .collection('Appointments')
              .doc(widget.appointment!.appointmentId)
              .update(updatedData);

          _showSnackBar('Appointment updated successfully!');
          Navigator.pop(context);
        });
  }

  Future<void> _saveAppointment({
    required DateTime selectedDate,
    required String startTime,
    required String endTime,
    required String serviceName,
    required double servicePrice,
    required String teamMemberName,
    required String description,
  }) async {
    FirebaseFirestore.instance
        .collection('Salons')
        .where('ownerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
          if (value.docs.isEmpty) {
            _showSnackBar('No salon found for this user');
            return;
          }
          Salon salon = Salon.fromMap(value.docs.first.data());
          CollectionReference appointments = FirebaseFirestore.instance
              .collection('Appointments');

          ServiceModel serviceModel = ServiceModel(
            title: serviceName,
            category: 'Self Service',
            price: servicePrice,
            description: description,
            duration: _selectedDuration!,
          );

          Map<String, dynamic> data =
              AppointmentModel(
                appointmentId: '',
                userId: FirebaseAuth.instance.currentUser!.uid,
                salonId: value.docs.first.id,
                date: selectedDate,
                services: [
                  {
                    'service': serviceModel,
                    'teamMember': Team(name: teamMemberName, imageLink: ''),
                  },
                ],
                total: servicePrice,
                paymentMethod: 'Pay at venue',
                createdAt: Timestamp.fromDate(DateTime.now()),
                salonModel: salon,
                ownerId: FirebaseAuth.instance.currentUser!.uid,
                startTime: startTime,
                endTime: endTime,
                currency: 'USD',
                status: 'Accepted',
              ).toMap();

          DocumentReference docRef = await appointments.add(data);
          await docRef.update({'appointmentId': docRef.id});
          _showSnackBar('Appointment booked successfully! ID: ${docRef.id}');
        });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  List<String> _selectedTeamMembers = [];

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Appointment')),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAppointmentfinal,
        child: const Icon(Icons.save),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverToBoxAdapter(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appointment Details",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _serviceNameController,
                        decoration: _inputDecoration("Service Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _servicePriceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Service Price"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _teamMemberNameController,
                        decoration: _inputDecoration("Team Member Name"),
                        readOnly: true,
                        onTap: () async {
                          final List<String> allMembers = List.generate(
                            widget.salon!.team.length,
                            (value) => widget.salon!.team[value].name,
                          );
                          final selected = await showDialog<List<String>>(
                            context: context,
                            builder: (context) {
                              List<String> tempSelected = List.from(
                                _selectedTeamMembers,
                              );
                              return AlertDialog(
                                title: Text('Select Team Members'),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children:
                                            allMembers.map((member) {
                                              return CheckboxListTile(
                                                value: tempSelected.contains(
                                                  member,
                                                ),
                                                title: Text(member),
                                                onChanged: (isChecked) {
                                                  setState(() {
                                                    if (isChecked!) {
                                                      tempSelected.add(member);
                                                    } else {
                                                      tempSelected.remove(
                                                        member,
                                                      );
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                      ),
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(
                                          context,
                                          tempSelected,
                                        ),
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (selected != null) {
                            _selectedTeamMembers = selected;
                            _teamMemberNameController.text = selected.join(
                              ', ',
                            );
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: _inputDecoration("Description"),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Appointment Date & Time",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Start Date: ${formatDate(_selectedDate!)}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickStartDate,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Start Time: ${formatTime(_startTime!)}"),
                        trailing: const Icon(Icons.access_time),
                        onTap: _pickStartTime,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "End Time: ${_endTime ?? "Select duration"}",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Appointment Duration",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children:
                            durationOptions.map((duration) {
                              return ChoiceChip(
                                label: Text(formatDuration(duration)),
                                selected: _selectedDuration == duration,
                                onSelected: (isSelected) {
                                  setState(() {
                                    _selectedDuration =
                                        isSelected ? duration : null;
                                    _calculateEndTime();
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
