part of 'home_page_cubit.dart';

@immutable
abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageDataLoaded extends HomePageState {
  final UserModel? user; // Single user data
  final List<Map<String, dynamic>> appointments; // List of appointments

  HomePageDataLoaded({this.user, required this.appointments});
}

class HomePageError extends HomePageState {
  final String message;

  HomePageError(this.message);
}
