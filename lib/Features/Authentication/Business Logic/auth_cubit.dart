import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_repo.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryClass _authRepository = AuthRepositoryClass();
  late final Stream<User?> _authStateChanges;

  AuthCubit() : super(AuthInitial()) {
    _authStateChanges = FirebaseAuth.instance.authStateChanges();
    _authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthSuccess(userData: user));
      } else {
        emit(const AuthFailure('User not authenticated'));
      }
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmailandSaveUserData(
        UserModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
        ),
      );

      if (user != null) {
        emit(AuthSuccess(userData: user));
      } else {
        emit(const AuthFailure('Sign-up failed'));
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'This email is already in use.';
            break;
          default:
            errorMessage = 'An unexpected error occurred!';
            break;
        }
      } else {
        errorMessage = e.toString();
      }
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user =
          await _authRepository.signInWithEmailandGetUserData(email, password);
      if (user != null) {
        emit(AuthSuccess(userData: user));
      } else {
        emit(const AuthFailure('Sign-in failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInAnonymously() async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        emit(AuthSuccess(userData: user));
      } else {
        emit(const AuthFailure('Anonymous sign-in failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        emit(const AuthFailure('Google Sign-in aborted by user'));
        return;
      }

      // Obtain the Google Sign-In Authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        emit(AuthSuccess(userData: user));

        UserModel userModel = UserModel(
          firstName: user.displayName ?? "Your first Name",
          lastName: null,
          email: user.email ?? "Your Email Adress",
          password: null,
          phoneNumber: user.phoneNumber ?? '',
          imageUrl: user.photoURL,
        );

        _authRepository.saveUserToFirestore(user.uid, userModel);
      } else {
        emit(const AuthFailure('Google Sign-in failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signout() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
