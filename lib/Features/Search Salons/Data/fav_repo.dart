import 'package:lexyapp/Features/Search%20Salons/Data/fav_source.dart';

class FavouritesRepository {
  final FavouritesSource favouritesSource = FavouritesSource();

  // Function to get the favourites list
  Future<List<String>> getFavourites(String userId) {
    return favouritesSource.getFavourites(userId);
  }

  // Function to add a salon to the favourites list and update count
  Future<void> addSalonToFavourites(String userId, String salonId) async {
    try {
      await favouritesSource.addSalonToFavourites(userId, salonId);
    } catch (error) {
      throw Exception("Error adding salon to favourites: $error");
    }
  }
}
