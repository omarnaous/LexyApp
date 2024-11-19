import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:meta/meta.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomePageCubit() : super(HomePageInitial()) {
    initializeListeners();
  }

  void initializeListeners() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Emit an empty user model and empty appointments if no user is logged in
      emit(HomePageDataLoaded(
        user: UserModel(
          firstName: '',
          lastName: '',
          email: '',
          phoneNumber: '',
          appointments: [],
          favourites: [],
          imageUrl: '',
        ),
        appointments: [],
      ));
      return;
    }

    final userId = currentUser.uid;

    // Listen to the current user's Firestore document
    _firestore.collection('users').doc(userId).snapshots().listen(
      (snapshot) {
        try {
          if (snapshot.exists) {
            final userData = snapshot.data();
            if (userData != null) {
              final userModel = UserModel.fromMap(userData);

              // Retain existing appointments if available
              final currentAppointments = state is HomePageDataLoaded
                  ? (state as HomePageDataLoaded).appointments
                  : <Map<String, dynamic>>[];

              emit(HomePageDataLoaded(
                user: userModel,
                appointments: currentAppointments,
              ));
            } else {
              emit(HomePageError('User data is null.'));
            }
          } else {
            emit(HomePageError('No document found for the current user.'));
          }
        } catch (e) {
          emit(HomePageError('Failed to fetch user data: $e'));
        }
      },
      onError: (error) {
        emit(HomePageError('User listener encountered an error: $error'));
      },
    );

    // Listen to the appointments where userId = current user's ID
    _firestore
        .collection('Appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          final appointments = snapshot.docs.map((doc) {
            return doc.data();
          }).toList();

          // Retain existing user if available
          final currentUser = state is HomePageDataLoaded
              ? (state as HomePageDataLoaded).user
              : null;

          emit(HomePageDataLoaded(
            user: currentUser,
            appointments: appointments,
          ));
        } catch (e) {
          emit(HomePageError('Failed to fetch appointments: $e'));
        }
      },
      onError: (error) {
        emit(HomePageError(
            'Appointments listener encountered an error: $error'));
      },
    );
  }
}
