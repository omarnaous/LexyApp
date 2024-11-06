import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';

class ProfileManagementProvider {
  // Method to update existing user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .update(data);
  }

  // Method to save new user data
  Future<void> saveUserData(Map<String, dynamic> data) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .set(
            data,
            SetOptions(
                merge:
                    true)); // Merge true ensures data is added if document exists
  }
}
