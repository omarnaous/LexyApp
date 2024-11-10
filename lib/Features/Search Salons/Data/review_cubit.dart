import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/review_repo.dart';
import 'package:lexyapp/general_widget.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _reviewRepository = ReviewRepository();

  ReviewCubit() : super(ReviewInitial());

  Future<void> submitReview({
    required BuildContext context,
    required String salonId,
    required int rating,
    required String description,
    required DateTime date,
  }) async {
    emit(ReviewSubmitting());

    try {
      // Fetch the current user's information using FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If user is not logged in, show error and stop submission
        showCustomSnackBar(
          context,
          "Error",
          "You must be logged in to submit a review.",
          isError: true,
        );
        return;
      }

      // Fetch user's information from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found in database.");
      }

      // Map Firestore data to UserModel
      UserModel userModel = UserModel.fromMap(userDoc.data()!);

      // Submit review using the ReviewRepository
      await _reviewRepository.submitReview(
        salonId: salonId,
        userId: user.uid,
        user: userModel.firstName,
        rating: rating,
        description: description,
        date: date,
      );

      emit(ReviewSubmitted());

      showCustomSnackBar(
        context,
        "Review Submitted",
        "Your review was submitted successfully!",
      );
      Navigator.of(context).pop();
    } catch (error) {
      emit(const ReviewSubmissionError(
          "Failed to submit review. Please try again."));

      showCustomSnackBar(
        context,
        "Error",
        "Failed to submit your review. Please try again.",
        isError: true,
      );
    }
  }
}
