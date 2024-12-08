class BusinessUserModel {
  final String email;
  final String
      password; // Storing password as plain text (not recommended for production)
  final String phoneNumber;
  final String businessOwnerName;
  final bool isBusinessUser;

  BusinessUserModel({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.businessOwnerName,
    this.isBusinessUser = true, // Default value set to true
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password, // Include the password directly
      'phoneNumber': phoneNumber,
      'businessOwnerName': businessOwnerName,
      'isBusinessUser': isBusinessUser,
    };
  }

  @override
  String toString() {
    return 'BusinessUserModel(email: $email, password: $password, phoneNumber: $phoneNumber, businessOwnerName: $businessOwnerName, isBusinessUser: $isBusinessUser)';
  }
}
