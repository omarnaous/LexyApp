import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/edit_profile.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Widgets/custom_tile.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _notificationsEnabled = true; // Default value for notifications

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AuthSuccess) {
            User? user = state.userData;
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // Profile Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                "Personal Profile",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          const Spacer(),
                          user?.photoURL != null
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      NetworkImage(user!.photoURL!),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                ),
                        ],
                      ),
                    ),
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
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return EditProfilePage();
                                  },
                                ));
                                // Navigate to profile page or any other action
                              },
                            ),
                            // Notifications with Switch
                            CustomListTile(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              onTap: () {},
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Separate Card for Terms and Policies
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: Column(
                          children: [
                            CustomListTile(
                              icon: Icons.description,
                              title: 'Terms of Service',
                              onTap: () {
                                // Open terms of service
                              },
                            ),
                            CustomListTile(
                              icon: Icons.description,
                              title: 'Privacy Policy',
                              onTap: () {
                                // Open privacy policy
                              },
                            ),
                            CustomListTile(
                              icon: Icons.description,
                              title: 'Terms of Use',
                              onTap: () {
                                // Open terms of use
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Separate Card for Support and Rate Us
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: Column(
                          children: [
                            CustomListTile(
                              icon: Icons.support_agent,
                              title: 'Support',
                              onTap: () {
                                // Open support page
                              },
                            ),
                            CustomListTile(
                              icon: Icons.star_rate,
                              title: 'Rate Us',
                              onTap: () {
                                // Open rate us page
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Separate Card for Logout
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: CustomListTile(
                          icon: Icons.logout,
                          title: 'Log out',
                          onTap: () {
                            context.read<AuthCubit>().signout();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
