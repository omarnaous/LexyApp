import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Admin/Pages/admin_panel.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/home_page.dart';
import 'package:lexyapp/Features/Notifications/notification_service.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/review_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/search_salons.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Logic/profile_mgt_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/profile.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/setup_bus_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/bus_calendar.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/setting_bus.dart';
import 'package:lexyapp/general_widget.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation
        .portraitDown, // Optional, allows upside-down portrait mode
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<NavBarCubit>(create: (context) => NavBarCubit()),
        BlocProvider<HomePageCubit>(create: (context) => HomePageCubit()),
        BlocProvider<AppointmentCubit>(create: (context) => AppointmentCubit()),
        BlocProvider<FavouritesCubit>(create: (context) => FavouritesCubit()),
        BlocProvider<ReviewCubit>(create: (context) => ReviewCubit()),
        BlocProvider<ProfileManagementCubit>(
          create: (context) => ProfileManagementCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Bottom Navigation Bar Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainApp(),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isBusinessUser = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isAdminUser = ValueNotifier<bool>(false);
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Check if the user is the admin
      if (currentUser!.email == "robertadmin@gmail.com") {
        isAdminUser.value = true;
        return;
      }

      // Check if the user is a business user
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

      if (userDoc.exists && userDoc.data()?['isBusinessUser'] == true) {
        isBusinessUser.value = true;
      }
    }
  }

  void _onItemTapped(int index) {
    if (currentUser == null && index == 2) {
      showCustomModalBottomSheet(context, const SignUpPage(), () {
        Navigator.of(context).pop();
        _selectedIndex.value = index;
      });
    } else {
      _selectedIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, selectedIndex, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isAdminUser,
          builder: (context, isAdmin, child) {
            if (isAdmin == true) {
              return const AdminPanelPage(); // Show different screen for admin
            }

            return ValueListenableBuilder<bool>(
              valueListenable: isBusinessUser,
              builder: (context, isBusiness, child) {
                return Scaffold(
                  body: IndexedStack(
                    index: selectedIndex,
                    children:
                        isBusiness ? _buildBusinessScreens() : _buildScreens(),
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: _onItemTapped,
                    items: isBusiness ? _businessNavBarItems() : _navBarItems(),
                    selectedItemColor: Colors.deepPurple,
                    unselectedItemColor: Colors.purple.shade200,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildScreens() {
    return [
      const MainHomePage(),
      const SearchSalonsPage(),
      const MyProfilePage(),
    ];
  }

  List<Widget> _buildBusinessScreens() {
    return [
      const SetupBusinessPage(),
      const ScheduleBusinessPage(),
      const SearchSalonsPage(),
      const BusinessSettingsPage(),
    ];
  }

  List<BottomNavigationBarItem> _navBarItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];
  }

  List<BottomNavigationBarItem> _businessNavBarItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: "Appointments",
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Settings",
      ),
    ];
  }
}

// Placeholder Admin Dashboard
