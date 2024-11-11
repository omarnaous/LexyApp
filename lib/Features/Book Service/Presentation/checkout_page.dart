import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/ratings_widget.dart';
import 'package:lexyapp/custom_image.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({
    super.key,
    required this.memberName,
    required this.date,
    required this.salonId,
    required this.services,
  });

  final Team memberName;
  final DateTime date;
  final String salonId;
  final List<Service> services;

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String _selectedPaymentMethod = 'Pay at venue';

  @override
  Widget build(BuildContext context) {
    // Calculate subtotal dynamically based on services
    double subtotal =
        // ignore: avoid_types_as_parameter_names
        widget.services.fold(0, (sum, service) => sum + service.price);
    double total = subtotal; // Total is the same as subtotal since no discount

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review and Confirm'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SalonCheckOutCard(salonId: widget.salonId),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, d MMM yyyy').format(widget.date),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(widget.date),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        itemCount: widget.services.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                title: Text(widget.services[index].title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    widget.services[index].description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: Text(
                                    "\$ ${widget.services[index].price.toStringAsFixed(2)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ),
                              if (index < widget.services.length - 1)
                                const Divider(
                                  thickness: 1.0,
                                  height: 0,
                                  color: Colors.grey,
                                ),
                            ],
                          );
                        },
                      ),
                      const Divider(thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text("\$ ${subtotal.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                            Text("\$ ${total.toStringAsFixed(2)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Payment method',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: RadioListTile(
                      value: 'Pay at venue',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text(
                        'Pay at venue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Cash'),
                      secondary: const Icon(Icons.store_mall_directory),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Changed to deep purple
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onPressed: () async {
            Future<void> saveAppointment({
              required String userId,
              required String salonId,
              required DateTime date,
              required List<Service> services,
              required double total,
              required String paymentMethod,
              String currency = 'USD', // Default currency set to USD
            }) async {
              try {
                // Reference to the Firestore appointments collection
                CollectionReference appointmentsRef =
                    FirebaseFirestore.instance.collection('Appointments');

                // Generate a unique document ID
                String appointmentId = appointmentsRef.doc().id;

                // Prepare data to be saved
                Map<String, dynamic> appointmentData = {
                  'appointmentId': appointmentId,
                  'userId': userId,
                  'salonId': salonId,
                  'date': date,
                  'services':
                      services.map((service) => service.toMap()).toList(),
                  'total': total,
                  'currency': currency, // Add currency field
                  'paymentMethod': paymentMethod,
                  'createdAt': FieldValue.serverTimestamp(), // Add timestamp
                };

                // Save data to Firestore
                await appointmentsRef.doc(appointmentId).set(appointmentData);

                print('Appointment saved successfully with ID: $appointmentId');
              } catch (e) {
                print('Failed to save appointment: $e');
              }
            }

            await saveAppointment(
                userId: FirebaseAuth.instance.currentUser!.uid,
                salonId: widget.salonId,
                date: widget.date,
                services: widget.services,
                total: total,
                paymentMethod: 'Cash');

            // Handle confirm booking action
            if (kDebugMode) {
              print('Booking Confirmed:');
              print('Salon ID: ${widget.salonId}');
              print('Date: ${widget.date}');
              print(
                  'Services: ${widget.services.map((e) => e.title).join(', ')}');
              print('Subtotal: JOD ${subtotal.toStringAsFixed(2)}');
              print('Total: JOD ${total.toStringAsFixed(2)}');
              print('Payment Method: $_selectedPaymentMethod');
            }
            // Add further confirmation logic here (e.g., navigating to a confirmation page)
          },
          child: const Text(
            'Confirm Appointment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class SalonCheckOutCard extends StatelessWidget {
  final String salonId;

  const SalonCheckOutCard({
    super.key,
    required this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    // Reference to the specific salon document
    DocumentReference salonRef =
        FirebaseFirestore.instance.collection('Salons').doc(salonId);

    return StreamBuilder<DocumentSnapshot>(
      stream: salonRef.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        // Show a loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if the document exists
        if (!snapshot.data!.exists) {
          return const Center(child: Text('Salon does not exist'));
        }

        // Extract data from the document
        Map<String, dynamic> data =
            snapshot.data!.data()! as Map<String, dynamic>;

        Salon salon = Salon.fromMap(data);

        double calculateAverageRating(List<Review> reviews) {
          if (reviews.isEmpty) return 0.0;
          return reviews
                  .map((review) => review.rating)
                  .reduce((a, b) => a + b) /
              reviews.length;
        }

        double averageRating = calculateAverageRating(salon.reviews);

        // Display the salon details
        return Card(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(
                    imageUrl:
                        salon.imageUrls.isNotEmpty ? salon.imageUrls[0] : '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      RatingsWidget(
                          rating: averageRating,
                          totalRatings: salon.reviews.length),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        salon.city,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
