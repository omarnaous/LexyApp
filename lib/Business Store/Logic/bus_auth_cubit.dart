// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lexyapp/Business%20Store/Logic/bus_auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());

//   // Sign-up method
//   Future<void> signUp({
//     required String businessName,
//     required String businessOwner,
//     required String contactNumber,
//     required String email,
//     required String password,
//   }) async {
//     emit(AuthLoading()); // Emit loading state
//     try {
//       // Save user data to Firestore
//       await FirebaseFirestore.instance.collection('businessUsers').add({
//         'businessName': businessName,
//         'businessOwner': businessOwner,
//         'contactNumber': contactNumber,
//         'email': email,
//         'password': password,
//       });
//       emit(AuthAuthenticated(email)); // Emit authenticated state
//     } catch (e) {
//       emit(AuthError('Failed to sign up: ${e.toString()}')); // Emit error state
//     }
//   }

//   // Sign-in method (checks if email exists)
//   Future<void> signIn(String email, String password) async {
//     emit(AuthLoading()); // Emit loading state
//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('businessUsers')
//           .where('email', isEqualTo: email)
//           .where('password', isEqualTo: password)
//           .get();

//       if (query.docs.isNotEmpty) {
//         emit(AuthAuthenticated(email)); // Emit authenticated state
//       } else {
//         emit(AuthUnauthenticated()); // Emit unauthenticated state
//       }
//     } catch (e) {
//       emit(AuthError('Failed to sign in: ${e.toString()}')); // Emit error state
//     }
//   }

//   // Sign-out method
//   void signOut() {
//     emit(AuthUnauthenticated()); // Emit unauthenticated state
//   }
// }
