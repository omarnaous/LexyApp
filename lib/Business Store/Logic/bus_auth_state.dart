// Base State
abstract class AuthState {}

// Initial State
class AuthInitial extends AuthState {}

// Loading State
class AuthLoading extends AuthState {}

// Authenticated State
class AuthAuthenticated extends AuthState {
  final String email;

  AuthAuthenticated(this.email);
}

// Unauthenticated State
class AuthUnauthenticated extends AuthState {}

// Error State
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
