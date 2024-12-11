import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_repo.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Business%20Store/Data/bus_user_model.dart';
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

  Future<void> signUpBusinessUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String businessOwnerName,
    required BuildContext context,
  }) async {
    emit(AuthLoading());
    try {
      // Sign up the business user and save user details
      await _authRepository
          .signUpWithEmailAndSaveBusinessUser(
        BusinessUserModel(
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          businessOwnerName: businessOwnerName,
          isBusinessUser: true,
        ),
      )
          .then((user) async {
        if (user != null) {
          // Create a new Salon model and save it to Firestore
          final salonId =
              FirebaseFirestore.instance.collection('Salons').doc().id;

          final emptySalon = Salon(
            workingDays: [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
            ],
            name: '', // Initialize with an empty name
            about: '', // Initialize with an empty about
            imageUrls: [], // Initialize with an empty image list
            location: const GeoPoint(0, 0), // Default location
            reviews: [], // Initialize with no reviews
            city: '', // Initialize with an empty city
            services: [], // Initialize with no services
            favourites: [], // Initialize with an empty favourites list
            count: 0, // Initialize count as 0
            team: [], // Initialize with an empty team
            ownerUid: user.uid, // Owner UID is the Firebase Auth UID
            active: false, // Initialize as not active
            openingTime: Timestamp.fromDate(
                DateTime(1970, 1, 1, 8, 0)), // Opening at 8:00 AM
            closingTime: Timestamp.fromDate(
                DateTime(1970, 1, 1, 20, 0)), // Closing at 8:00 PM
          );

          await FirebaseFirestore.instance
              .collection('Salons')
              .doc(salonId)
              .set(emptySalon.toMap());

          emit(AuthSuccess(userData: user));
          // ignore: use_build_context_synchronously
          BlocProvider.of<HomePageCubit>(context).initializeListeners();
        } else {
          emit(const AuthFailure('Business user sign-up failed'));
        }
      });
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
    } finally {
      emit(AuthInitial()); // Reset the state to initial once done
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        emit(const AuthFailure('Google Sign-in aborted by user'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        emit(AuthSuccess(userData: user));

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          UserModel userModel = UserModel(
            firstName: user.displayName ?? "Your First Name",
            lastName: null,
            email: user.email ?? "Your Email Address",
            password: null,
            phoneNumber: user.phoneNumber ?? '',
            imageUrl: user.photoURL,
          );

          await _authRepository.saveUserToFirestore(user.uid, userModel);
        }
      } else {
        emit(const AuthFailure('Google Sign-in failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithApple(context) async {
    emit(AuthLoading());
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256OfString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user != null) {
        emit(AuthSuccess(userData: user));

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          UserModel userModel = UserModel(
            firstName: appleCredential.givenName ?? user.displayName ?? "",
            lastName: appleCredential.familyName ?? "",
            email: user.email ?? "Your Email Address",
            password: null,
            phoneNumber: user.phoneNumber ?? '',
            imageUrl: user.photoURL,
          );

          await _authRepository.saveUserToFirestore(user.uid, userModel);
        }
      } else {
        emit(const AuthFailure('Apple Sign-in failed'));
      }
    } catch (e) {
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
