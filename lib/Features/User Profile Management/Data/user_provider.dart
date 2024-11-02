import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';

class ProfileManagementProvider {
  Future updateUserData(Map<String, dynamic> data) async {
    AuthServiceClass authSourceClass = AuthServiceClass();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(authSourceClass.currentUserId)
        .update(data);
  }
}
