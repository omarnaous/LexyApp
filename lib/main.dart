import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/setup_bus_page.dart';
import 'package:lexyapp/Features/Notifications/notification_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/signup_page.dart';
import 'package:lexyapp/Features/Book%20Service/Data/appointment_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Pages/home_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/review_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Logic/favourites_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/search_salons.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Logic/profile_mgt_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/profile.dart';
import 'package:lexyapp/general_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<ProfileManagementCubit>(
          create: (context) => ProfileManagementCubit(),
        ),
        BlocProvider<NavBarCubit>(
          create: (context) => NavBarCubit(),
        ),
        BlocProvider<FavouritesCubit>(
          create: (context) => FavouritesCubit(),
        ),
        BlocProvider<ReviewCubit>(
          create: (context) => ReviewCubit(),
        ),
        BlocProvider<AppointmentCubit>(
          create: (context) => AppointmentCubit(),
        ),
        BlocProvider<HomePageCubit>(
          create: (context) => HomePageCubit(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        title: 'Flutter Persistent Bottom Nav Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context)
                .scaffoldBackgroundColor, // Set the background color
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
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
  PersistentTabController? _controller;
  bool isBusinessUser = false; // Default to non-business user
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Check Firestore to determine if the user is a business user
      final userDoc = await FirebaseFirestore.instance
          .collection(
              'users') // Replace 'users' with your Firestore collection name
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data()?['isBusinessUser'] == true) {
        setState(() {
          isBusinessUser = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NavBarCubit, bool>(
        builder: (context, isNavBarVisible) {
          return PersistentTabView(
            backgroundColor: Theme.of(context).colorScheme.surface,
            context,
            controller: _controller!,
            screens: isBusinessUser ? _buildBusinessScreens() : _buildScreens(),
            items: isBusinessUser
                ? _businessNavBarsItems(context)
                : _navBarsItems(context),
            onItemSelected: (int index) {
              if (currentUser == null && index == 2) {
                // Open modal for SignUpPage when user is null and Profile tab is selected
                showCustomModalBottomSheet(context, const SignUpPage(), () {
                  Navigator.of(context).pop();
                  context
                      .read<NavBarCubit>()
                      .showNavBar(); // Show NavBar on modal close
                });
                context
                    .read<NavBarCubit>()
                    .hideNavBar(); // Hide NavBar while modal is open
              } else if (currentUser != null && index == 2) {
                _controller!
                    .jumpToTab(2); // Navigate to Profile if user is signed in
              }
            },
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardAppears: true,
            padding: const EdgeInsets.only(top: 8),
            isVisible: isNavBarVisible,
            animationSettings: const NavBarAnimationSettings(
              navBarItemAnimation: ItemAnimationSettings(
                duration: Duration(milliseconds: 400),
                curve: Curves.ease,
              ),
              screenTransitionAnimation: ScreenTransitionAnimationSettings(
                animateTabTransition: true,
                duration: Duration(milliseconds: 200),
                screenTransitionAnimationType:
                    ScreenTransitionAnimationType.slide,
              ),
            ),
            confineToSafeArea: true,
            navBarHeight: kBottomNavigationBarHeight,
            navBarStyle: NavBarStyle.style12,
          );
        },
      ),
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
      const SearchSalonsPage(),

      Scaffold(),
      // const BusinessHomePage(), // Replace with your business-specific home page
      // const BusinessSearchPage(), // Replace with your business-specific search page
      // const BusinessProfilePage(), // Replace with your business-specific profile page
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: "Search",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _businessNavBarsItems(BuildContext context) {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.business),
        title: "Dashboard",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.analytics),
        title: "Analytics",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: "Settings",
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
