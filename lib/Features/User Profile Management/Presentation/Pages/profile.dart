import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/edit_profile.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Widgets/custom_tile.dart';
import 'package:lexyapp/general_widget.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _notificationsEnabled = true; // Default value for notifications
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                await context
                    .read<AuthCubit>()
                    .deleteAccount(context)
                    .then((_) {
                  BlocProvider.of<HomePageCubit>(context).initializeListeners();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting account: $error")),
                  );
                });
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // Profile Header
                  SliverToBoxAdapter(
                    child: StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel userModel =
                                UserModel.fromMap(snapshot.data?.data() ?? {});

                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${userModel.firstName} ${userModel.lastName}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(
                                            height:
                                                4), // Spacing between name and profile text
                                        Text(
                                          "Personal Profile",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  userModel.imageUrl != null &&
                                          userModel.imageUrl!.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              NetworkImage(userModel.imageUrl!),
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.deepPurple[100],
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 24,
                                          ),
                                        ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),

                  // Main Settings Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: Column(
                          children: [
                            CustomListTile(
                              icon: Icons.person,
                              title: 'My Profile',
                              onTap: () {
                                context.read<NavBarCubit>().hideNavBar();
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return const EditProfilePage();
                                  },
                                ));
                              },
                            ),
                            // Notifications with Switch
                            // CustomListTile(
                            //   icon: Icons.notifications,
                            //   title: 'Notifications',
                            //   onTap: () {},
                            //   trailing: Switch(
                            //     value: _notificationsEnabled,
                            //     onChanged: (bool value) {
                            //       setState(() {
                            //         _notificationsEnabled = value;
                            //       });
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Separate Card for Terms and Policies
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Card(
                  //       child: Column(
                  //         children: [
                  //           CustomListTile(
                  //             icon: Icons.description,
                  //             title: 'Terms of Service',
                  //             onTap: () {
                  //               // Open terms of service
                  //             },
                  //           ),
                  //           CustomListTile(
                  //             icon: Icons.description,
                  //             title: 'Privacy Policy',
                  //             onTap: () {
                  //               // Open privacy policy
                  //             },
                  //           ),
                  //           CustomListTile(
                  //             icon: Icons.description,
                  //             title: 'Terms of Use',
                  //             onTap: () {
                  //               // Open terms of use
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // // Separate Card for Support and Rate Us
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Card(
                  //       child: Column(
                  //         children: [
                  //           CustomListTile(
                  //             icon: Icons.support_agent,
                  //             title: 'Support',
                  //             onTap: () {
                  //               // Open support page
                  //             },
                  //           ),
                  //           CustomListTile(
                  //             icon: Icons.star_rate,
                  //             title: 'Rate Us',
                  //             onTap: () {
                  //               // Open rate us page
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: CustomListTile(
                          icon: Icons.delete_forever,
                          title: 'Delete Account',
                          onTap: () {
                            _showDeleteConfirmationDialog(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: CustomListTile(
                          icon: Icons.logout,
                          title: 'Log out',
                          onTap: () {
                            context
                                .read<AuthCubit>()
                                .signout(context)
                                .whenComplete(() {
                              BlocProvider.of<HomePageCubit>(context)
                                  .initializeListeners();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<NavBarCubit>().hideNavBar();
                        showCustomModalBottomSheet(context, const SignUpPage(),
                            () {
                          Navigator.of(context).pop();
                          context.read<NavBarCubit>().showNavBar();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, // Set button color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "Please Sign In",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white, // Set text color
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
