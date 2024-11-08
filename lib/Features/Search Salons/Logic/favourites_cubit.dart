import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/fav_repo.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  final FavouritesRepository repository = FavouritesRepository();
  FavouritesCubit() : super(FavouritesInitial());

  // Function to add salonId to favourites
  void addSalonToFavourites(String salonId) async {
    emit(FavouritesLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(FavouritesError("User not authenticated"));
        return;
      }

      final currentFavourites = await repository.getFavourites(userId);

      if (currentFavourites.contains(salonId)) {
        // Emit an error if the salon is already in favourites
        emit(FavouritesError("Salon is already in favourites"));
      } else {
        // Add salon to favourites via the repository
        await repository.addSalonToFavourites(userId, salonId);
        emit(FavouritesAdded()); // Emit success state
      }
    } catch (error) {
      emit(FavouritesError("Error updating favourites: $error"));
    }
  }
}
