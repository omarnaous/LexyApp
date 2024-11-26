import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send verification code and handle phone verification
  Future<void> sendVerificationCode({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(String verificationId) onTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // No action here as we do not want to sign in automatically
          print(
              "Verification completed automatically. Credential: $credential");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed with error: ${e.message}");
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Code sent successfully. Verification ID: $verificationId");
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout reached. Verification ID: $verificationId");
          onTimeout(verificationId);
        },
      );
    } catch (e) {
      print("Error during phone verification: $e");
    }
  }
}
