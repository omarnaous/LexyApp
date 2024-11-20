import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_repo.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';

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
    required context,
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
        BlocProvider.of<HomePageCubit>(context).initializeListeners();
      } else {
        emit(const AuthFailure('Sign-up failed'));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            emit(const AuthFailure('The password provided is too weak.'));
            break;
          case 'email-already-in-use':
            emit(const AuthFailure('This email is already in use.'));
            break;
          default:
            emit(AuthFailure('An unexpected error occurred: ${e.message}'));
            break;
        }
      } else {
        emit(AuthFailure(e.toString()));
      }
    }
  }

  Future<void> signInWithEmail(String email, String password, context) async {
    emit(AuthLoading());
    try {
      final user =
          await _authRepository.signInWithEmailandGetUserData(email, password);
      if (user != null) {
        emit(AuthSuccess(userData: user));
        BlocProvider.of<HomePageCubit>(context).initializeListeners();
      } else {
        emit(const AuthFailure('Sign-in failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle(context) async {
    emit(AuthLoading());
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels the login
      if (googleUser == null) {
        emit(const AuthFailure('Google Sign-in aborted by user'));
        return;
      }

      // Retrieve Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create an OAuth credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        emit(AuthSuccess(userData: user));

        // Check if the user document exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Save user details to Firestore if the document does not exist
          UserModel userModel = UserModel(
            firstName: user.displayName ?? "Your First Name",
            lastName: null,
            email: user.email ?? "Your Email Address",
            password: null,
            phoneNumber: user.phoneNumber ?? '',
            imageUrl: user.photoURL,
          );

          await _authRepository.saveUserToFirestore(user.uid, userModel);
          print('User saved to Firestore');
        } else {
          print('User document already exists in Firestore');
        }
      } else {
        emit(const AuthFailure('Google Sign-in failed'));
      }
    } catch (e) {
      print('Error during Google Sign-in: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithApple(context) async {
    emit(AuthLoading());
    try {
      // Generate a nonce
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256OfString(rawNonce);

      // Get Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user != null) {
        emit(AuthSuccess(userData: user));

        // Check if the user document exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Save user details to Firestore if not already saved
          UserModel userModel = UserModel(
            firstName: appleCredential.givenName ?? user.displayName ?? "",
            lastName: appleCredential.familyName ?? "",
            email: user.email ?? "Your Email Address",
            password: null,
            phoneNumber: user.phoneNumber ?? '',
            imageUrl: user.photoURL,
          );

          await _authRepository.saveUserToFirestore(user.uid, userModel);
          print('User saved to Firestore');
        } else {
          print('User document already exists in Firestore');
        }
      } else {
        emit(const AuthFailure('Apple Sign-in failed'));
      }
    } catch (e) {
      print(e.toString());
      emit(AuthFailure('Apple Sign-in failed: $e'));
    }
  }

  Future<void> signout(context) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
      BlocProvider.of<HomePageCubit>(context).initializeListeners();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List<int>.generate(length,
        (_) => charset.codeUnitAt(DateTime.now().millisecond % charset.length));
    return String.fromCharCodes(random);
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
