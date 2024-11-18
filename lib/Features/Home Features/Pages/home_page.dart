import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/home_content.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isAtBottom = _scrollController.position.atEdge &&
            _scrollController.position.pixels != 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Stream<Map<String, dynamic>> _fetchCombinedStream() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Stream.value({});
    }

    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? {
                'user':
                    UserModel.fromMap(snapshot.data() as Map<String, dynamic>)
              }
            : {'user': null});

    final appointmentsStream = FirebaseFirestore.instance
        .collection('Appointments')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            {'appointments': snapshot.docs.map((doc) => doc.data()).toList()});

    return CombineLatestStream.combine2(
      userStream,
      appointmentsStream,
      (user, appointments) => {
        ...user,
        ...appointments,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _fetchCombinedStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userModel = snapshot.data!['user'] as UserModel;
              final appointments =
                  snapshot.data!['appointments'] as List<Map<String, dynamic>>;

              return HomePageContent(
                userModel: userModel,
                appointments: appointments,
                scrollController: _scrollController,
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      floatingActionButton: !_isAtBottom
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              tooltip: "Scroll Down",
              child: const Icon(
                Icons.keyboard_double_arrow_down_sharp,
                size: 40,
              ),
            )
          : null,
    );
  }
}
