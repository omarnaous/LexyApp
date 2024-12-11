// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/confirm_button.dart';
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
    this.showConfirmButton = true,
    required this.salon,
  });

  final List<Map<String, dynamic>> services;
  final String salonId;
  final DateTime? date;
  final bool showConfirmButton;
  final Salon salon;

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String _selectedPaymentMethod = 'Pay at venue';

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.services.fold(
      0,
      (sum, item) => sum + (item['service'] as ServiceModel).price,
    );
    double total = subtotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review and Confirm'),
      ),
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
                child: SalonDetailsCheckOutCard(salonId: widget.salonId),
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
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 0,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  teamMember.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
      bottomNavigationBar: widget.showConfirmButton
          ? ConfirmButton(
              subtotal: subtotal,
              total: total,
              selectedPaymentMethod: _selectedPaymentMethod,
              onSaveAppointment: () async {
                context.read<AppointmentCubit>().createAppointment(
                      salonModel: widget.salon,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      salonId: widget.salonId,
                      date: widget.date ?? DateTime(0),
                      services: widget.services,
                      total: total,
                      paymentMethod: _selectedPaymentMethod,
                      context: context,
                    );
              },
            )
          : null,
    );
  }
}
