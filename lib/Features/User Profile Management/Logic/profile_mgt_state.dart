abstract class ProfileManagementState {
  const ProfileManagementState();
}

class ProfileManagementInitial extends ProfileManagementState {}

class ProfileManagementLoading extends ProfileManagementState {}

class ProfileManagementSuccess extends ProfileManagementState {}

class ProfileManagementError extends ProfileManagementState {
  final String message;

  const ProfileManagementError(this.message);
}
