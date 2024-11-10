import 'package:lexyapp/Features/Search%20Salons/Data/review_source.dart';

class ReviewRepository {
  final ReviewSource _reviewSource = ReviewSource();

  // Fetch all reviews for a given salon
  Future<List<Map<String, dynamic>>> fetchSalonReviews(String salonId) {
    return _reviewSource.getReviews(salonId);
  }

  // Add a review to a salon
  Future<void> submitReview({
    required String salonId,
    required String userId,
    required String user,
    required int rating,
    required String description,
    required DateTime date,
  }) {
    return _reviewSource.addReview(
      salonId,
      userId,
      user,
      rating,
      description,
      date,
    );
  }
}
