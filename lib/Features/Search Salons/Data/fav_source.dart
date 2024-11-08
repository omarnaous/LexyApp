import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouritesSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch the user's favourites
  Future<List<String>> getFavourites(String userId) async {
    try {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      return List<String>.from(userDoc.data()?["favourites"] ?? []);
    } catch (error) {
      throw Exception("Error fetching favourites: $error");
    }
  }

  // Add a salon to the user's favourites and update count in Salons collection
  Future<void> addSalonToFavourites(String userId, String salonId) async {
    try {
      // Fetch user document to get current favourites
      var userDoc = await _firestore.collection('users').doc(userId).get();
      List<String> favouritesSaved =
          List<String>.from(userDoc.data()?["favourites"] ?? []);

      // Check if salon is not already in favourites
      if (!favouritesSaved.contains(salonId)) {
        // Add salonId to user's favourites list
        favouritesSaved.add(salonId);
        await _firestore.collection('users').doc(userId).update({
          "favourites": favouritesSaved,
        });

        // Fetch the current count of the salon in the Salons collection
        var salonDoc = await _firestore.collection('Salons').doc(salonId).get();
        int currentCount = (salonDoc.data()?["count"] ?? 0) as int;

        // Increment the count and update it in Firestore
        await _firestore.collection('Salons').doc(salonId).update({
          "count": currentCount + 1,
        });
      }
    } catch (error) {
      throw Exception("Error adding salon to favourites: $error");
    }
  }
}
