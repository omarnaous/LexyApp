import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Admin/Pages/banners.dart';
import 'package:lexyapp/Admin/Pages/salons_maage.dart';
import 'package:lexyapp/Admin/Pages/send_notifs.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/setting_bus.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/main.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.deepPurple,
        title: const Text("Admin Panel"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const BannerImagesPage();
                      },
                    ),
                  );
                },
                child: const Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text('Banner Images'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SalonManagement();
                      },
                    ),
                  );
                },
                child: const Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text('Manage Salons'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SendNotificationPage();
                      },
                    ),
                  );
                },
                child: const Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text('Send Notifications'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  context.read<AuthCubit>().signout(context).whenComplete(() {
                    BlocProvider.of<HomePageCubit>(context)
                        .initializeListeners();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                        return MyApp();
                      }),
                      (route) =>
                          false, // Ensures all previous routes are removed
                    );
                  });
                },
                child: const Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text('Sign out'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
