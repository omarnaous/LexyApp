part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User? userData;

  const AuthSuccess({this.userData});
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);
}
