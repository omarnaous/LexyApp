// Cubit states
abstract class FavouritesState {}

class FavouritesInitial extends FavouritesState {}

class FavouritesLoading extends FavouritesState {}

class FavouritesAdded extends FavouritesState {}

class FavouritesError extends FavouritesState {
  final String message;
  FavouritesError(this.message);
}
