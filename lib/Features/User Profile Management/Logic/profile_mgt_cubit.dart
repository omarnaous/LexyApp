import 'package:bloc/bloc.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Data/user_repo.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Logic/profile_mgt_state.dart';

class ProfileManagementCubit extends Cubit<ProfileManagementState> {
  final ProfileManagementRepo _profileManagementRepo = ProfileManagementRepo();

  ProfileManagementCubit() : super(ProfileManagementInitial());

  Future<void> updateUserData(UserModel userModel) async {
    emit(ProfileManagementLoading());

    try {
      // Use the repository instance to update user data
      await _profileManagementRepo.updateUserData(userModel);

      emit(ProfileManagementSuccess());
    } catch (e) {
      emit(ProfileManagementError("Failed to update profile: ${e.toString()}"));
    }
  }

  Future<void> saveUserData(UserModel userModel) async {
    emit(ProfileManagementLoading());

    try {
      // Use the repository instance to save new user data
      await _profileManagementRepo.saveUserData(userModel);

      emit(ProfileManagementSuccess());
    } catch (e) {
      emit(ProfileManagementError("Failed to save profile: ${e.toString()}"));
    }
  }
}
