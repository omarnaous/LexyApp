import 'package:bloc/bloc.dart';

class NavBarCubit extends Cubit<bool> {
  NavBarCubit() : super(true);

  void showNavBar() => emit(true);

  void hideNavBar() => emit(false);
}
