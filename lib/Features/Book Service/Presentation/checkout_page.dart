// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/payment_method.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/salon_details_check.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
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
        showCustomSnackBar(
          context,
          'Error',
          'User not logged in.',
        );
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
        'services': widget.services.map((service) {
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

      final formattedDate =
          DateFormat('EEE, d MMM yyyy hh:mm a').format(widget.date!);

      showCustomSnackBar(
        context,
        'Success',
        'Your appointment has been created successfully. Scheduled for $formattedDate.',
      );

      // Navigate to the main page or close the current page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (Route<dynamic> route) => false,
      );

      context.read<NavBarCubit>().hideNavBar();
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
      appBar: AppBar(
        title: const Text('Review and Confirm'),
      ),
      floatingActionButton:
          widget.isAdmin == null && widget.status != 'Needs Checkout'
              ? FloatingActionButton.extended(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("Appointments")
                        .doc(widget.appointmentId)
                        .update({'status': 'Cancelled by Client'});

                    showCustomSnackBar(context, 'Appointment Cancelled!',
                        'This Appointment is Cancelled');
                  },
                  label: const Text(
                    "Cancel Reservation",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
              : Container(),
      body: BlocListener<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentSuccess) {
            final formattedDate = widget.date != null
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SalonDetailsCheckOutCard(salonId: widget.salonId),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Date',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      formatDate(widget.date!),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'From: ${widget.startTime} till ${widget.endTime}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Status: ${widget.status}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 16)),
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
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Services List',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...widget.services.map((item) {
                      final service = item['service'] as ServiceModel;
                      // final teamMember = item['teamMember'] as Team;

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
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${service.duration} mins",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
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
            const SliverToBoxAdapter(
              child: SizedBox(height: 50),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.status == 'Needs Checkout' &&
              widget.isAdmin == null
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
              ? Padding(
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
                            showCustomSnackBar(
                              context,
                              'Appointment Accepted!',
                              'You have accepted the appointment.',
                            );
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
                )
              : const SizedBox.shrink(),
    );
  }
}
