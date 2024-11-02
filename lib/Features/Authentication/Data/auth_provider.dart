import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServiceClass {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Firestore

  // Stream to listen for authentication changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String get currentUserId => _auth.currentUser!.uid;

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) {
    return _auth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .then((userCredential) => userCredential.user);
  }

  // Register with email and password
  Future<User?> createUserWithEmailPassword(
      String email, String password, Map<String, dynamic> userData) async {
    User? user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    if (user != null) {
      // Save user data to Firestore
      await saveUserToFirestore(user.uid, userData);
    }

    return user;
  }

  // Function to save user data to Firestore
  Future<void> saveUserToFirestore(
      String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  // Sign out
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
