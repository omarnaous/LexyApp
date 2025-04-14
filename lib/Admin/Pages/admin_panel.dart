import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Admin/Pages/banners.dart';
import 'package:lexyapp/Admin/Pages/salons_maage.dart';
import 'package:lexyapp/Admin/Pages/send_notifs.dart';
import 'package:lexyapp/Admin/Pages/user_management.dart';
import 'package:lexyapp/Admin/manage_categories.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/bus_auth.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/search_salons.dart';
import 'package:lexyapp/main.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.deepPurple,
        title: const Text("Admin Panel", style: TextStyle(color: Colors.white)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildAdminPanel(), const SearchSalonsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Salons',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanel() {
    return CustomScrollView(
      slivers: [
        _buildMenuItem(
          title: 'Banner Images',
          icon: Icons.image,
          page: const BannerImagesPage(),
        ),
        _buildMenuItem(
          title: 'Users',
          icon: Icons.people,
          page: const UsersManagement(),
        ),
        _buildMenuItem(
          title: 'Create Salons',
          icon: Icons.add_business,
          page: const BusinessSignUp(isAdmin: true),
        ),
        _buildMenuItem(
          title: 'Manage Salons',
          icon: Icons.storefront,
          page: const SalonManagement(),
        ),
        _buildMenuItem(
          title: 'Send Notifications',
          icon: Icons.notifications_active,
          page: const SendNotificationPage(),
        ),
        _buildMenuItem(
          title: 'Manage Categories',
          icon: Icons.category,
          page: const ManageCategoriesPage(),
        ),
        _buildMenuItem(
          title: 'Sign Out',
          icon: Icons.exit_to_app,
          action: () {
            context.read<AuthCubit>().signout(context).whenComplete(() {
              BlocProvider.of<HomePageCubit>(context).initializeListeners();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MyApp()),
                (route) => false,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    Widget? page,
    VoidCallback? action,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap:
              action ??
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => page!));
              },
          child: Card(
            elevation: 3,
            child: ListTile(
              leading: Icon(icon, color: Colors.deepPurple),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
