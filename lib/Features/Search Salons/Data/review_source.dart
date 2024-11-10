import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all reviews for a given salon
  Future<List<Map<String, dynamic>>> getReviews(String salonId) async {
    try {
      QuerySnapshot reviewSnapshot = await _firestore
          .collection('Salons')
          .doc(salonId)
          .collection('reviews')
          .orderBy('date', descending: true)
          .get();

      // Return a list of raw maps representing reviews
      return reviewSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      throw Exception("Error fetching reviews: $error");
    }
  }

  // Add a review to a salon
  Future<void> addReview(String salonId, String userId, String user, int rating,
      String description, DateTime date) async {
    try {
      await _firestore.collection('Salons').doc(salonId).update({
        "reviews": [
          {
            'userId': userId,
            'user': user,
            'rating': rating,
            'description': description,
            'date': date.toIso8601String(),
          }
        ]
      });
    } catch (error) {
      throw Exception("Error adding review: $error");
    }
  }
}
