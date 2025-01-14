import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/review_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_textfield.dart';
import 'package:lexyapp/general_widget.dart';

class SalonReviewsPage extends StatefulWidget {
  const SalonReviewsPage({
    super.key,
    required this.salon,
    required this.salonId,
  });

  final Salon salon;
  final String salonId;

  @override
  State<SalonReviewsPage> createState() => _SalonReviewsPageState();
}

class _SalonReviewsPageState extends State<SalonReviewsPage> {
  final TextEditingController _reviewController = TextEditingController();
  final List<Review> _reviews = [];
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _reviews.addAll(widget.salon.reviews);

    // Sort reviews by the latest date first
    _reviews.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.deepPurple,
          size: 20,
        );
      }),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _selectedRating = index + 1;
            });
          },
          icon: Icon(
            Icons.star,
            color: index < _selectedRating ? Colors.deepPurple : Colors.grey,
            size: 30,
          ),
        );
      }),
    );
  }

  void _submitReview(BuildContext context) {
    final salonReviewsCubit = context.read<ReviewCubit>();

    salonReviewsCubit.submitReview(
      context: context,
      salonId: widget.salonId,
      rating: _selectedRating,
      description: _reviewController.text,
      date: DateTime.now(),
    );

    // Clear text fields and reset rating
    setState(() {
      _reviewController.clear();
      _selectedRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Salon Reviews",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final review = _reviews[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.user,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildRatingStars(review.rating),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.description,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(review.date),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: _reviews.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildStarSelector(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _reviewController,
                          labelText: "Add a review...",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a review";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () {
                          if (_reviewController.text.isNotEmpty &&
                              _selectedRating > 0) {
                            if (FirebaseAuth.instance.currentUser == null) {
                              showCustomModalBottomSheet(
                                context,
                                const SignUpPage(),
                                () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }
                            _submitReview(context);
                          } else {
                            showCustomSnackBar(
                              context,
                              "Error",
                              "Please provide a rating and review text.",
                              isError: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
