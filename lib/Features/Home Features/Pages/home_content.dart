import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/fav_page.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/user_appointments.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/appointment_card.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/empty_list.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/fav_card.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/image_carousel.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/section_header.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/general_widget.dart';

class HomePageContent extends StatefulWidget {
  final UserModel? userModel;
  final List appointments;
  final ScrollController scrollController;

  const HomePageContent({
    super.key,
    required this.userModel,
    required this.appointments,
    required this.scrollController,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _getAppointmentStatus(DateTime appointmentDate) {
    final now = DateTime.now();
    final difference = appointmentDate.difference(now);

    if (difference.isNegative) {
      final daysAgo = difference.inDays.abs();
      return daysAgo == 0
          ? "Passed today"
          : "Passed $daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago";
    } else {
      final daysAhead = difference.inDays;
      return daysAhead == 0
          ? "Happening today"
          : "In $daysAhead ${daysAhead == 1 ? 'day' : 'days'}";
    }
  }

  List<Map<String, dynamic>> _sortAppointments(List appointments) {
    List<AppointmentModel> parsedAppointments =
        appointments.map((e) => AppointmentModel.fromMap(e)).toList();

    parsedAppointments.sort((a, b) {
      if (a.date.isAfter(DateTime.now()) && b.date.isBefore(DateTime.now())) {
        return -1;
      } else if (a.date.isBefore(DateTime.now()) &&
          b.date.isAfter(DateTime.now())) {
        return 1;
      } else {
        return a.date.compareTo(b.date);
      }
    });

    return parsedAppointments.map((e) => e.toMap()).toList();
  }

  Stream<List<Map<String, dynamic>>> _streamFavouriteSalons(
      List<String>? favouriteIds) async* {
    if (favouriteIds == null || favouriteIds.isEmpty) {
      yield [];
      return;
    }

    try {
      final salonSnapshots = await Future.wait(
        favouriteIds.map(
          (id) => FirebaseFirestore.instance.collection('Salons').doc(id).get(),
        ),
      );

      final salons = salonSnapshots
          .where((snapshot) => snapshot.exists)
          .map((snapshot) => snapshot.data() as Map<String, dynamic>)
          .toList();

      yield salons;
    } catch (e) {
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedAppointments =
        _sortAppointments(widget.appointments);

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Hey, ${widget.userModel?.firstName}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 25),
        ),
        const SliverToBoxAdapter(
          child: SlidingImagesSection(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 25),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: "My Favourites",
              onViewAll: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  context.read<NavBarCubit>().hideNavBar();

                  showCustomModalBottomSheet(context, const SignUpPage(), () {
                    context.read<NavBarCubit>().showNavBar();
                    Navigator.of(context).pop();
                  });
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return LikesPage(data: widget.userModel!.favourites!);
                    },
                  ));
                }
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 15),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamFavouriteSalons(widget.userModel?.favourites),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyListWarning(
                text: 'No Favourites added',
              );
            }

            List<Map<String, dynamic>> favouriteSalons = snapshot.data!;

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  height:
                      200, // Adjusted height for the horizontal scrollable list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    itemCount: favouriteSalons.length,
                    itemBuilder: (context, index) {
                      Salon salon = Salon.fromMap(favouriteSalons[index]);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: FavCard(
                          salon: salon,
                          widget: widget,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 25),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: "My Appointments",
              onViewAll: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const AppointmentScheduler();
                  },
                ));
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 10),
        ),
        sortedAppointments.isEmpty
            ? const EmptyListWarning(
                text: 'No Appointments Available',
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    AppointmentModel appointment =
                        AppointmentModel.fromMap(sortedAppointments[index]);
                    String status = _getAppointmentStatus(appointment.date);
                    String formattedDateTime =
                        DateFormat('EEE, MMM d, yyyy hh:mm a')
                            .format(appointment.date);

                    return AppointmentCard(
                      appointment: appointment,
                      formattedDateTime: formattedDateTime,
                      status: status,
                    );
                  },
                  childCount: sortedAppointments.length,
                ),
              ),
      ],
    );
  }
}
