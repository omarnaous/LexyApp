import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Data/user_provider.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  final PhoneNumber phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isResendEnabled = false;
  int _timerSeconds = 30;
  Timer? _timer;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _timerSeconds = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendOtp() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber.international,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          showCustomSnackBar(
            context,
            'Failed to Resend OTP',
            e.message ?? 'An error occurred while resending OTP',
            isError: true,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          showCustomSnackBar(
            context,
            'OTP Resent',
            'A new OTP has been sent to ${widget.phoneNumber.international}',
          );
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      showCustomSnackBar(
        context,
        'Error',
        'An error occurred while resending OTP: $e',
        isError: true,
      );
    }
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      showCustomSnackBar(
        context,
        'Invalid OTP',
        'Please enter a valid 6-digit OTP',
        isError: true,
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // Verify OTP with Firebase Authentication
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Update the phone number in Firestore
      final fullPhoneNumber = widget.phoneNumber.international;
      await ProfileManagementProvider()
          .updateUserData({'phoneNumber': fullPhoneNumber});

      showCustomSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Verification Successful',
        'Phone number has been verified and updated successfully!',
      );

      // Navigate back to close the OTP screen
      Navigator.pop(context); // Close the OTP screen
    } catch (e) {
      showCustomSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Verification Failed',
        'Error verifying OTP: ${e.toString()}',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text.rich(
              TextSpan(
                text: 'We sent a code to ',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: widget.phoneNumber.international,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Pinput(
              controller: _otpController,
              length: 6,
              keyboardType: TextInputType.number,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
              ),
              onCompleted: (pin) {
                _otpController.text = pin; // Ensure pin is set
                _verifyOtp();
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isResendEnabled ? _resendOtp : null,
              child: Text(
                _isResendEnabled
                    ? 'Resend Code'
                    : 'Resend Code in $_timerSeconds seconds',
                style: TextStyle(
                  color: _isResendEnabled
                      ? Colors.deepPurple
                      : Colors.deepPurple.shade200,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
