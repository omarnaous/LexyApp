// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:lexyapp/Business%20Store/Presentation/Pages/client_information.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/custom_appt.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/payment_method.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/salon_details_check.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Notifications/notification_service.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:lexyapp/main.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({
    super.key,
    required this.services,
    required this.salonId,
    required this.date,
    this.appointmentId,
    required this.salon,
    this.status,
    this.startTime,
    this.endTime,
    this.isAdmin,
    this.requestedUserId,
    this.isEdit,
  });

  final List<Map<String, dynamic>> services;
  final String salonId;
  final DateTime? date;
  final String? appointmentId;
  final Salon salon;
  final String? status;
  final String? startTime;
  final String? endTime;
  final bool? isAdmin;
  final String? requestedUserId;
  final bool? isEdit;

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String _selectedPaymentMethod = 'Pay at venue';

  Future<void> _confirmAppointment(double total) async {
    if (widget.date == null) {
      showCustomSnackBar(
        context,
        'Error',
        'Please select a date for the appointment.',
      );
      return;
    }

    try {
      // Get the current user's ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        showCustomSnackBar(context, 'Error', 'User not logged in.');
        return;
      }

      // Prepare the data to be added to Firestore
      final appointmentData = {
        'startTime': widget.startTime!,
        'endTime': widget.endTime!,
        'appointmentId': '', // Placeholder, will be updated later
        'userId': userId,
        'salonId': widget.salonId,
        'date': widget.date!,
        'services':
            widget.services.map((service) {
              final serviceModel = service['service'] as ServiceModel;
              final teamMember = service['teamMember'] as Team;
              return {
                'service': serviceModel.toMap(),
                'teamMember': teamMember.toMap(),
              };
            }).toList(),
        'total': total,
        'paymentMethod': _selectedPaymentMethod,
        'createdAt': Timestamp.now(),
        'salonModel': widget.salon.toMap(),
        'ownerId': widget.salon.ownerUid,
        'status': 'Waiting Approval',
      };

      // Use a WriteBatch for atomic writes
      final batch = FirebaseFirestore.instance.batch();
      final docRef =
          FirebaseFirestore.instance.collection('Appointments').doc();
      batch.set(docRef, appointmentData);
      batch.update(docRef, {'appointmentId': docRef.id});
      await batch.commit();

      final formattedDate = DateFormat(
        'EEE, d MMM yyyy hh:mm a',
      ).format(widget.date!);

      showCustomSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Success',
        'Your appointment has been created successfully. Scheduled for $formattedDate.',
      );

      // Navigate to the main page or close the current page
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (Route<dynamic> route) => false,
      );

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) async {
            UserModel userModel = UserModel.fromMap(value.data()!);
            NotificationService.instance.sendNotification(
              targetUserId: widget.salon.ownerUid,
              title: 'New Appointment Request',
              body:
                  'You have a new appointment request from ${userModel.firstName} ${userModel.lastName}.\nTap to View Details',
            );
          });

      // context.read<NavBarCubit>().hideNavBar();
    } catch (e) {
      showCustomSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'Failed to create appointment: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.status);
    double subtotal = widget.services.fold(
      0,
      (sum, item) => sum + (item['service'] as ServiceModel).price,
    );
    double total = subtotal;

    String formatDate(DateTime date) {
      return DateFormat('d MMM yyyy').format(date);
    }

    print(widget.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Review and Confirm')),
      floatingActionButton:
          widget.isEdit == true
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Construct the appointment model instance using the checkout details.
                  AppointmentModel appointment = AppointmentModel(
                    appointmentId: widget.appointmentId ?? "",
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    salonId: widget.salonId,
                    date: widget.date!,
                    services: widget.services,
                    total: widget.services.fold(
                      0,
                      (sum, item) =>
                          sum + (item['service'] as ServiceModel).price,
                    ),
                    paymentMethod: _selectedPaymentMethod,
                    createdAt:
                        Timestamp.now(), // Use the original createdAt if available
                    salonModel: widget.salon,
                    ownerId: widget.salon.ownerUid,
                    startTime: widget.startTime!,
                    endTime: widget.endTime!,
                    currency: 'USD',
                    status: widget.status ?? 'Waiting Approval',
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomAppointmentPage(
                          salon: widget.salon,
                          selectedDate: widget.date,
                          isEdit: true,
                          appointment: appointment,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Appointment"),
              )
              : widget.isAdmin == null && widget.status != 'Needs Checkout'
              ? FloatingActionButton.extended(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("Appointments")
                      .doc(widget.appointmentId)
                      .update({'status': 'Cancelled by Client'});
                  showCustomSnackBar(
                    context,
                    'Appointment Cancelled!',
                    'This Appointment is Cancelled',
                  );
                },
                label: const Text(
                  "Cancel Reservation",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Container(),

      body: BlocListener<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentSuccess) {
            final formattedDate =
                widget.date != null
                    ? DateFormat('EEE, d MMM yyyy hh:mm a').format(widget.date!)
                    : 'No specific date';

            showCustomSnackBar(
              context,
              'Appointment Successful!',
              'Your appointment is scheduled for $formattedDate.',
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
              (Route<dynamic> route) => false,
            );
            context.read<NavBarCubit>().hideNavBar();
          } else if (state is AppointmentFailure) {
            showCustomSnackBar(
              context,
              'Unexpected Error!',
              'Failed to create appointment: ${state.error}',
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SalonDetailsCheckOutCard(salonId: widget.salonId)],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatDate(widget.date!),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'From: ${widget.startTime} till ${widget.endTime}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Status: ${widget.status}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PaymentMethodSelection(
                selectedPaymentMethod: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value.toString();
                  });
                },
              ),
            ),
            widget.isAdmin == true
                ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection(
                                  'users',
                                ) // Replace 'users' with your collection name
                                .doc(
                                  widget.requestedUserId,
                                ) // Fetch document by user ID
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading...'));
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const ListTile(title: Text('No data found'));
                          }
                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          UserModel userModel = UserModel.fromMap(userData);
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ClientInformationPage(
                                      userModel: userModel,
                                    );
                                  },
                                ),
                              );
                            },
                            child: ListTile(
                              title: const Text(
                                'Client Information',
                                style: TextStyle(
                                  fontSize: 18.0, // Larger font size
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                              ),
                              subtitle: Text(
                                '${userModel.firstName} ${userModel.lastName}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                ), // Optional: Smaller font for subtitle
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
                : const SliverToBoxAdapter(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Services List',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...widget.services.map((item) {
                      final service = item['service'] as ServiceModel;
                      final teamMember = item['teamMember'] as Team;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "(${teamMember.name}) - ${service.duration} mins",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'USD ${service.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      );
                    }),
                    const Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'USD ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.status == 'Needs Checkout' && widget.isAdmin == null
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _confirmAppointment(total);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              : widget.status == 'Waiting Approval' && widget.isAdmin == true
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Appointments")
                                .doc(widget.appointmentId)
                                .update({'status': 'Accepted'});

                            NotificationService.instance.sendNotification(
                              title: 'Appointment Request Accepted',
                              body:
                                  'Your appointment request has been approved. Check your schedule for details.',
                              targetUserId: widget.requestedUserId!,
                            );

                            showCustomSnackBar(
                              context,
                              'Appointment Accepted!',
                              'You have accepted the appointment.',
                            );
                            void _addEventToCalendar() {
                              if (widget.date == null ||
                                  widget.startTime == null ||
                                  widget.endTime == null) {
                                showCustomSnackBar(
                                  context,
                                  'Error',
                                  'Date or time information is missing.',
                                );
                                return;
                              }

                              // Parse the start and end times
                              final startDateTime = DateTime.parse(
                                '${DateFormat('yyyy-MM-dd').format(widget.date!)} ${widget.startTime}',
                              );
                              final endDateTime = DateTime.parse(
                                '${DateFormat('yyyy-MM-dd').format(widget.date!)} ${widget.endTime}',
                              );

                              // Get the list of services and team members
                              final servicesDescription = widget.services
                                  .map((service) {
                                    final serviceModel =
                                        service['service'] as ServiceModel;
                                    final teamMember =
                                        service['teamMember'] as Team;
                                    return '${serviceModel.title} (${teamMember.name})';
                                  })
                                  .join(", ");

                              // Create the event
                              final Event event = Event(
                                title: 'Appointment with ${widget.salon.name}',
                                description: 'Services: $servicesDescription',
                                location:
                                    widget.salon.city ?? "No location provided",
                                startDate: startDateTime,
                                endDate: endDateTime,
                                iosParams: const IOSParams(
                                  reminder: Duration(
                                    minutes: 30,
                                  ), // Reminder for iOS
                                ),
                                androidParams: const AndroidParams(
                                  emailInvites:
                                      [], // Optional email invites for Android
                                ),
                              );

                              // Add the event to the calendar
                              Add2Calendar.addEvent2Cal(event)
                                  .then((_) {
                                    showCustomSnackBar(
                                      context,
                                      'Event Added',
                                      'The appointment has been added to your calendar.',
                                    );
                                  })
                                  .catchError((error) {
                                    showCustomSnackBar(
                                      context,
                                      'Error',
                                      'Failed to add event to calendar: $error',
                                    );
                                  });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Appointments")
                                .doc(widget.appointmentId)
                                .update({'status': 'Rejected'});
                            showCustomSnackBar(
                              context,
                              'Appointment Rejected!',
                              'You have rejected the appointment.',
                            );

                            NotificationService.instance.sendNotification(
                              title: 'Appointment Request Rejected',
                              body:
                                  'Unfortunately, your appointment request was not approved. Please try rescheduling or contact support for assistance.',
                              targetUserId: widget.requestedUserId!,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
