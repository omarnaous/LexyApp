import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';

class ProfileManagementRepo {
  // Method to update existing user data
  Future<void> updateUserData(UserModel userModel) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    // Update Firestore user data
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .update(userModel.toMap());
  }

  // Method to save new user data if it doesn't exist
  Future<void> saveUserData(UserModel userModel) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    // Save new user data, merging with existing data if present
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .set(userModel.toMap(), SetOptions(merge: true));
  }
}
