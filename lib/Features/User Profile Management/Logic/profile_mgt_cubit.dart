import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lexyapp/Features/Authentication/Data/auth_provider.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Logic/profile_mgt_state.dart';

class ProfileManagementCubit extends Cubit<ProfileManagementState> {
  ProfileManagementCubit() : super(ProfileManagementInitial());

  Future<void> updateUserData(UserModel userModel) async {
    emit(ProfileManagementLoading());

    try {
      AuthServiceClass authSourceClass = AuthServiceClass();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(authSourceClass.currentUserId)
          .update(userModel.toMap());

      emit(ProfileManagementSuccess());
    } catch (e) {
      emit(ProfileManagementError("Failed to update profile: ${e.toString()}"));
    }
  }
}
