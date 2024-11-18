import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_state.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/appointment_date.dart';
import 'package:lexyapp/Features/Book%20Service/Widgets/appointment_services.dart';
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
    required this.teamMember,
    required this.date,
    required this.salonId,
    required this.services,
    this.showConfirmButton = true, // Default to true
  });

  final Team teamMember;
  final DateTime date;
  final String salonId;
  final List<ServiceModel> services;
  final bool showConfirmButton; // New optional parameter

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String _selectedPaymentMethod = 'Pay at venue';

  @override
  Widget build(BuildContext context) {
    double subtotal =
        widget.services.fold(0, (sum, service) => sum + service.price);
    double total = subtotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review and Confirm'),
      ),
      body: BlocListener<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentSuccess) {
            final formattedDate =
                DateFormat('EEE, d MMM yyyy hh:mm a').format(widget.date);

            showCustomSnackBar(
              context,
              'Appointment Successful!',
              'Your appointment is scheduled for $formattedDate.',
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MyApp()), // Replace with your home page
              (Route<dynamic> route) => false, // Removes all previous routes
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SalonDetailsCheckOutCard(salonId: widget.salonId),
              ),
            ),
            SliverToBoxAdapter(
              child: AppointmentDateCheckOut(
                date: widget.date,
                teamMember: widget.teamMember,
              ),
            ),
            SliverToBoxAdapter(
              child: AppointmentServicesCheckOut(
                services: widget.services,
                subtotal: subtotal,
                total: total,
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
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      salonId: widget.salonId,
                      date: widget.date,
                      services: widget.services,
                      total: total,
                      paymentMethod: _selectedPaymentMethod,
                      context: context,
                    );
              },
            )
          : null, // If `showConfirmButton` is false, no button is shown
    );
  }
}
