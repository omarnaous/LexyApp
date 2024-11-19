import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/home_content.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: BlocConsumer<HomePageCubit, HomePageState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is HomePageDataLoaded) {
            if (kDebugMode) {
              // print(state.user);
            }

            return HomePageContent(
              userModel: state.user,
              appointments: state.appointments,
              scrollController: _scrollController,
            );
          }
          return const Scaffold();
        },
      )),
    );
  }
}
