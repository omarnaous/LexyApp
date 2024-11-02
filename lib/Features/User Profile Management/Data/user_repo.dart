import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';

class ProfileManagementRepo {
  Future<void> updateUserData(
    UserModel userModel,
  ) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    // Update Firestore user data
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .update(userModel.toMap());
  }
}
