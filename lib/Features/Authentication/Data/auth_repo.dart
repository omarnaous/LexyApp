import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Business%20Store/Data/bus_user_model.dart';

class AuthRepositoryClass {
  final AuthServiceClass _authService = AuthServiceClass();

  // Sign up with email and save user data
  Future<User?> signUpWithEmailandSaveUserData(UserModel userModel) {
    return _authService.createUserWithEmailPassword(
        userModel.email, userModel.password!, userModel.toMap());
  }

  Future<void> saveUserToFirestore(String userId, UserModel userModel) async {
    await _authService.saveUserToFirestore(userId, userModel.toMap());
  }

  // Sign in with email and get user data
  Future<User?> signInWithEmailandGetUserData(String email, String password) {
    return _authService.signInWithEmailPassword(email, password);
  }

  // Sign up with email and save Business User data
  Future<User?> signUpWithEmailAndSaveBusinessUser(
      BusinessUserModel businessUserModel) {
    return _authService.createUserWithEmailPassword(businessUserModel.email,
        businessUserModel.password, businessUserModel.toMap());
  }

  Future<void> saveBusinessUserToFirestore(
      String userId, BusinessUserModel businessUserModel) async {
    await _authService.saveUserToFirestore(userId, businessUserModel.toMap());
  }

  // Listen to authentication changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Optionally, you can provide a sign-out method
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
