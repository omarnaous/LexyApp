import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_model.dart';
import 'package:lexyapp/Features/Book%20Service/Presentation/checkout_page.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/image_carousel.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/section_header.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/salon_details.dart';
import 'package:lexyapp/custom_image.dart';
import 'package:lexyapp/main.dart';

class HomePageContent extends StatefulWidget {
  final UserModel? userModel;
  final List<Map<String, dynamic>> appointments;
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
  late UserModel _cachedUserModel;

  @override
  void initState() {
    super.initState();
    _cachedUserModel = widget.userModel ?? UserModel.fromMap({});
  }

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

  List<Map<String, dynamic>> _sortAppointments(
      List<Map<String, dynamic>> appointments) {
    List<Appointment> parsedAppointments =
        appointments.map((e) => Appointment.fromMap(e)).toList();

    parsedAppointments.sort((a, b) {
      // Sort upcoming first, then overdue
      if (a.date.isAfter(DateTime.now()) && b.date.isBefore(DateTime.now())) {
        return -1; // `a` is upcoming, `b` is overdue
      } else if (a.date.isBefore(DateTime.now()) &&
          b.date.isAfter(DateTime.now())) {
        return 1; // `b` is upcoming, `a` is overdue
      } else {
        // Sort by date if both are in the same category
        return a.date.compareTo(b.date);
      }
    });

    return parsedAppointments.map((e) => e.toMap()).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchFavouriteSalons() async {
    if (_cachedUserModel.favourites == null ||
        _cachedUserModel.favourites!.isEmpty) {
      return [];
    }

    List<String> favouriteIds = List<String>.from(_cachedUserModel.favourites!);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Salons')
        .where(FieldPath.documentId, whereIn: favouriteIds)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Stream<List<Map<String, dynamic>>> _streamFavouriteSalons(
      List<String> favouriteIds) async* {
    if (favouriteIds.isEmpty) {
      yield []; // No favourites
      return;
    }

    try {
      final salonSnapshots = await Future.wait(
        favouriteIds.map(
          (id) => FirebaseFirestore.instance.collection('Salons').doc(id).get(),
        ),
      );

      final salons = salonSnapshots
          .where((snapshot) => snapshot.exists) // Ensure document exists
          .map((snapshot) => snapshot.data() as Map<String, dynamic>)
          .toList();

      yield salons;
    } catch (e) {
      print("Error fetching favourites: $e");
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
        SliverPadding(
          padding: const EdgeInsets.all(15.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  'Hey, ${_cachedUserModel.firstName}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SlidingImagesSection(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 15),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: "My Favourites",
              onViewAll: () {
                // Add logic to navigate to full favourites list
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _streamFavouriteSalons(widget.userModel?.favourites ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 240, // Match the fixed height of the list
                  child: Center(
                    child: Text(
                      "No favourites found.",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                );
              }

              List<Map<String, dynamic>> favouriteSalons = snapshot.data!;

              return SizedBox(
                height: 220, // Fixed height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favouriteSalons.length,
                  itemBuilder: (context, index) {
                    Salon salon = Salon.fromMap(favouriteSalons[index]);

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: AspectRatio(
                        aspectRatio:
                            4 / 3, // Maintain a consistent aspect ratio
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return SalonDetailsPage(
                                    salon: salon,
                                    salonId:
                                        widget.userModel!.favourites![index]);
                              },
                            ));
                            context.read<NavBarCubit>().hideNavBar();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      CustomImage(imageUrl: salon.imageUrls[0]),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                salon.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 5),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: "My Appointments",
              onViewAll: () {},
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 10),
        ),
        SliverList.builder(
          itemCount: sortedAppointments.length,
          itemBuilder: (context, index) {
            Appointment appointment =
                Appointment.fromMap(sortedAppointments[index]);
            String status = _getAppointmentStatus(appointment.date);
            String formattedDateTime =
                DateFormat('EEE, MMM d, yyyy hh:mm a').format(appointment.date);

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 0,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return CheckOutPage(
                            showConfirmButton: false,
                            teamMember: appointment.salonModel.team[0],
                            date: appointment.date,
                            salonId: appointment.salonId,
                            services: appointment.services);
                      },
                    ));
                  },
                  title: Text(
                    appointment.salonModel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("$formattedDateTime\n$status"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepPurple.shade400,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
